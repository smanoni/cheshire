#include "regs/cheshire.h"
#include "dif/clint.h"
#include "dif/uart.h"
#include "params.h"
#include "util.h"

// Problem size (just an example; K should be multiple of KTILE ideally)
#define M 64        // number of rows of A
#define K 64        // number of cols of A / length of x
#define REPEAT 2    // repeat GEMV to amplify timing

// Cache parameters for CVA6
#define L1_CACHE_SIZE_BYTES  2048
#define L1_CACHE_LINE_BIT    128
#define L1_CACHE_LINE_BYTES  (L1_CACHE_LINE_BIT / 8)

// Derived cache info
#define L1_CACHE_LINES  (L1_CACHE_SIZE_BYTES / L1_CACHE_LINE_BYTES)
#define ELEM_SIZE_BYTES (sizeof(uint64_t))

// Tile on columns: number of elements in a row that fit in one cache line
#define KTILE (L1_CACHE_LINE_BYTES / ELEM_SIZE_BYTES)

// Tile on rows: chosen from associativity reasoning
//#define MTILE (L1_CACHE_LINES - 2)
#define MTILE 32

static uint64_t A[M][K];
static uint64_t x[K];
static uint64_t y_baseline[M];
static uint64_t y_opt[M];

volatile uint64_t sink;

// ===============================
// Baseline GEMV
// Inner-product dataflow:
//
//   for each row i:
//     y[i] = sum_k A[i][k] * x[k]
//
// No tiling.
// ===============================
void gemv_baseline_inner_product(uint64_t *y_out) {
    for (int i = 0; i < M; i++) {
        uint64_t acc = 0;
        for (int k = 0; k < K; k++) {
            acc += A[i][k] * x[k];
        }
        y_out[i] = acc;
    }
}

// ===============================
// Optimized GEMV (still inner-product)
//
// 2D tiling on rows (M) and columns (K):
//
// for (i0 = 0; i0 < M; i0 += MTILE)
//   for (k0 = 0; k0 < K; k0 += KTILE)
//     for (i = i0; i < min(i0+MTILE, M); i++)
//       for (k = k0; k < min(k0+KTILE, K); k++)
//         y[i] += A[i][k] * x[k];
//
// Notes:
// - KTILE = elements per row that fit in one cache line.
// - MTILE chosen considering associativity.
// - Dataflow is still inner product: y[i] is sum over k, just
//   accumulated tile-by-tile.
// ===============================
void gemv_optimized_tiled_inner_product(uint64_t *y_out) {
    // Initialize y to 0, we'll accumulate tile contributions into it.
    for (int i = 0; i < M; i++) {
        y_out[i] = 0;
    }

    // Tile over rows (M dimension)
    for (int i0 = 0; i0 < M; i0 += MTILE) {
        int iend = i0 + MTILE;
        if (iend > M) {
            iend = M;
        }

        // Tile over columns (K dimension)
        for (int k0 = 0; k0 < K; k0 += KTILE) {
            int kend = k0 + KTILE;
            if (kend > K) {
                kend = K;
            }

            // For this (i0..iend, k0..kend) tile:
            // - x[k0..kend-1] fits in 1 cache line (KTILE elems).
            // - A[i][k0..kend-1] for i in [i0..iend) uses MTILE lines.
            // - y[i0..iend) accumulates partial sums.
            for (int i = i0; i < iend; i++) {
                uint64_t acc = y_out[i];  // current partial sum

                // Inner product over this column tile
                for (int k = k0; k < kend; k++) {
                    acc += A[i][k] * x[k];
                }

                y_out[i] = acc;
            }
        }
    }
}

int main(void)
{
    // UART init
    uint32_t rtc_freq   = *reg32(&__base_regs, CHESHIRE_RTC_FREQ_REG_OFFSET);
    uint64_t reset_freq = clint_get_core_freq(rtc_freq, 2500);
    uart_init(&__base_uart, reset_freq, __BOOT_BAUDRATE);

    char msg[512];   // one single output buffer
    int len = 0;

    // ===========================
    // Initialize A and x
    // ===========================
    for (int i = 0; i < M; i++) {
        for (int k = 0; k < K; k++) {
            A[i][k] = (uint64_t)(i + 1) * (k + 1);
        }
    }

    for (int k = 0; k < K; k++) {
        x[k] = (uint64_t)(k + 1);
    }

    uint64_t start_baseline, end_baseline;
    uint64_t start_opt, end_opt;
    uint64_t cycles_baseline, cycles_opt;

    // ===========================
    // Baseline GEMV timing
    // ===========================
    start_baseline = get_mcycle();
    for (int r = 0; r < REPEAT; r++) {
        gemv_baseline_inner_product(y_baseline);
    }
    end_baseline = get_mcycle();
    cycles_baseline = end_baseline - start_baseline;

    // ===========================
    // Optimized GEMV timing
    // ===========================
    start_opt = get_mcycle();
    for (int r = 0; r < REPEAT; r++) {
        gemv_optimized_tiled_inner_product(y_opt);
    }
    end_opt = get_mcycle();
    cycles_opt = end_opt - start_opt;

    // Use results to avoid dead-code elimination
    sink = y_baseline[0] ^ y_opt[0];

    // ===========================
    // BIST: compare y_baseline vs y_opt
    // ===========================
    int errors = 0;
    int first_err_idx = -1;
    uint64_t exp_val = 0;
    uint64_t got_val = 0;

    for (int i = 0; i < M; i++) {
        if (y_baseline[i] != y_opt[i]) {
            errors++;
            if (first_err_idx == -1) {
                first_err_idx = i;
                exp_val = y_baseline[i];
                got_val = y_opt[i];
            }
        }
    }

    // ===========================
    // Single UART print
    // ===========================
    if (errors == 0) {
        len = snprintf(msg, sizeof(msg),
            "Baseline:  start=%llu  end=%llu  cycles=%llu\r\n"
            "Optimized: start=%llu  end=%llu  cycles=%llu  (MTILE=%d, KTILE=%d)\r\n"
            "BIST: PASS (outputs match)\r\n",
            (unsigned long long)start_baseline,
            (unsigned long long)end_baseline,
            (unsigned long long)cycles_baseline,
            (unsigned long long)start_opt,
            (unsigned long long)end_opt,
            (unsigned long long)cycles_opt,
            MTILE, KTILE
        );
    } else {
        len = snprintf(msg, sizeof(msg),
            "Baseline:  start=%llu  end=%llu  cycles=%llu\r\n"
            "Optimized: start=%llu  end=%llu  cycles=%llu  (MTILE=%d, KTILE=%d)\r\n"
            "BIST: FAIL  errors=%d  first_mismatch_idx=%d  exp=0x%016llx  got=0x%016llx\r\n",
            (unsigned long long)start_baseline,
            (unsigned long long)end_baseline,
            (unsigned long long)cycles_baseline,
            (unsigned long long)start_opt,
            (unsigned long long)end_opt,
            (unsigned long long)cycles_opt,
            MTILE, KTILE,
            errors,
            first_err_idx,
            (unsigned long long)exp_val,
            (unsigned long long)got_val
        );
    }

    uart_write_str(&__base_uart, msg, len);
    uart_write_flush(&__base_uart);

    return 0;
}
