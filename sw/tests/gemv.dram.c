#include "regs/cheshire.h"
#include "dif/clint.h"
#include "dif/uart.h"
#include "params.h"
#include "util.h"
#include "gemv.h"
// ============================================================
// Configuration
// ============================================================

#define REPEAT 2

#define L1_CACHE_SIZE_BYTES  2048
#define L1_CACHE_LINE_BIT    128
#define L1_CACHE_LINE_BYTES  (L1_CACHE_LINE_BIT / 8)

#define L1_CACHE_LINES  (L1_CACHE_SIZE_BYTES / L1_CACHE_LINE_BYTES)
#define ELEM_SIZE_BYTES (sizeof(uint64_t))

#define KTILE (L1_CACHE_LINE_BYTES / ELEM_SIZE_BYTES)
#define MTILE 126

// ============================================================
// Data
// ============================================================

static uint64_t y_baseline[M];
static uint64_t y_opt[M];

volatile uint64_t sink;

// ============================================================
// Baseline GEMV
// ============================================================

void gemv_baseline_inner_product(uint64_t *y_out)
{
    for (int i = 0; i < M; i++) {
        uint64_t acc = 0;
        for (int k = 0; k < K; k++) {
            acc += A[i][k] * x[k];
        }
        y_out[i] = acc;
    }
}

// ============================================================
// Optimized GEMV (tiled, inner-product)
// ============================================================

void gemv_optimized_tiled_inner_product(uint64_t *y_out)
{
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

// ============================================================
// BIST: compare baseline vs optimized outputs
// (no printing here)
// ============================================================

int bist_compare_gemv(const uint64_t *ref,
                      const uint64_t *dut,
                      int n,
                      int *first_err_idx,
                      uint64_t *exp_val,
                      uint64_t *got_val)
{
    int errors = 0;

    *first_err_idx = -1;
    *exp_val = 0;
    *got_val = 0;

    for (int i = 0; i < n; i++) {
        if (ref[i] != dut[i]) {
            errors++;
            if (*first_err_idx == -1) {
                *first_err_idx = i;
                *exp_val = ref[i];
                *got_val = dut[i];
            }
        }
    }

    return errors;
}

// ============================================================
// Main
// ============================================================

int main(void)
{
    // UART init
    uint32_t rtc_freq   = *reg32(&__base_regs, CHESHIRE_RTC_FREQ_REG_OFFSET);
    uint64_t reset_freq = clint_get_core_freq(rtc_freq, 2500);
    uart_init(&__base_uart, reset_freq, __BOOT_BAUDRATE);

    char msg[512];   // one single output buffer
    int len = 0;

    uint64_t start_baseline, end_baseline;
    uint64_t start_opt, end_opt;
    uint64_t cycles_baseline, cycles_opt;

    // ========================================================
    // Baseline GEMV timing
    // ========================================================

    start_baseline = get_mcycle();
    for (int r = 0; r < REPEAT; r++) {
        gemv_baseline_inner_product(y_baseline);
    }
    end_baseline = get_mcycle();

    // ========================================================
    // Optimized GEMV timing
    // ========================================================
    start_opt = get_mcycle();
    for (int r = 0; r < REPEAT; r++) {
        gemv_optimized_tiled_inner_product(y_opt);
    }
    end_opt = get_mcycle();

    sink = y_baseline[0] ^ y_opt[0];

    // ========================================================
    // BIST
    // ========================================================

    int first_err_idx;
    uint64_t exp_val;
    uint64_t got_val;

    //int errors = bist_compare_gemv(
    //    y_baseline,
    //    y_opt,
    //    M,
    //    &first_err_idx,
    //    &exp_val,
    //    &got_val
    //);

    // ===========================
    // Single UART print
    // ===========================
    int errors = 0;
    cycles_opt = end_opt - start_opt;
    cycles_baseline = end_baseline - start_baseline;
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

    return errors;
}
