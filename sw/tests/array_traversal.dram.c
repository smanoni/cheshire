#include "regs/cheshire.h"
#include "dif/clint.h"
#include "dif/uart.h"
#include "params.h"
#include "util.h"
#include "matrix.h"

//#define N 32
#define REPEAT 2

//static uint64_t A[N][N];
volatile uint64_t sink;

// =========================
// Baseline: column-major (slow)
// Returns: sum (no timing here)
// =========================
uint64_t baseline_col_major(void) {
    uint64_t sum = 0;
    for (int r = 0; r < REPEAT; r++) {
        for (int j = 0; j < N; j++) {
            for (int i = 0; i < N; i++) {
                sum += A[i][j];
            }
        }
    }
    return sum;
}

// =========================
// Optimized: row-major (fast)
// Returns: sum (no timing here)
// =========================
uint64_t optimized_row_major(void) {
    uint64_t sum = 0;
    for (int r = 0; r < REPEAT; r++) {
        for (int i = 0; i < N; i++) {
            for (int j = 0; j < N; j++) {
                sum += A[i][j];
            }
        }
    }
    return sum;
}

int main(void)
{
    // UART init
    uint32_t rtc_freq   = *reg32(&__base_regs, CHESHIRE_RTC_FREQ_REG_OFFSET);
    uint64_t reset_freq = clint_get_core_freq(rtc_freq, 2500);

    uart_init(&__base_uart, reset_freq, __BOOT_BAUDRATE);

    char msg[64];
    int len;

    // Array Initialization
    //for (int i = 0; i < N; i++) {
    //    for (int j = 0; j < N; j++) {
    //        A[i][j] = (uint64_t)(i + j);
    //    }
    //}

    // ===========================
    // Measure in main
    // ===========================
    uint64_t start, end;
    uint64_t cycles_baseline, cycles_opt;

    // Baseline measurement
    start = get_mcycle();
    uint64_t sum_baseline = baseline_col_major();
    end = get_mcycle();
    cycles_baseline = end - start;

    // Optimized measurement
    start = get_mcycle();
    uint64_t sum_opt = optimized_row_major();
    end = get_mcycle();
    cycles_opt = end - start;

    // Use results to avoid optimizing them away
    sink = sum_baseline + sum_opt;

    // Print cycle results
    len = snprintf(msg, sizeof(msg), "baseline cycles = %llu\r\n",
                   (unsigned long long)cycles_baseline);
    uart_write_str(&__base_uart, msg, len);

    len = snprintf(msg, sizeof(msg), "optimized cycles = %llu\r\n",
                   (unsigned long long)cycles_opt);
    uart_write_str(&__base_uart, msg, len);

    uart_write_flush(&__base_uart);

    return 0;
}
