#!/usr/bin/env python3
import sys
import re
import matplotlib.pyplot as plt

# Signal names in the VCD (from $var lines)
MISS_NAME = "dcache_miss_o"
CYCLE_NAME = "cycle_q"


# ------------------------------------------------------------
# 1. Parse metrics (start/end cycles) from transcript
# ------------------------------------------------------------
def load_metrics_from_transcript(path):
    baseline_re = re.compile(r"Baseline:.*start=(\d+)\s+end=(\d+)")
    opt_re      = re.compile(r"Optimized:.*start=(\d+)\s+end=(\d+)")

    start_baseline = end_baseline = None
    start_opt = end_opt = None

    with open(path, "r", errors="ignore") as f:
        for line in f:
            line = line.strip()
            if "Baseline:" in line:
                m = baseline_re.search(line)
                if m:
                    start_baseline = int(m.group(1))
                    end_baseline   = int(m.group(2))
            elif "Optimized:" in line:
                m = opt_re.search(line)
                if m:
                    start_opt = int(m.group(1))
                    end_opt   = int(m.group(2))

    if None in (start_baseline, end_baseline, start_opt, end_opt):
        print(f"ERROR: Could not parse start/end timestamps from transcript {path}")
        sys.exit(1)

    return start_baseline, end_baseline, start_opt, end_opt


# ------------------------------------------------------------
# 2. Minimal VCD parser (only for dcache_miss_o and cycle_q)
# ------------------------------------------------------------
def parse_vcd(filename):
    miss_code = None
    cycle_code = None
    miss_tv = []
    cycle_tv = []

    with open(filename, "r", errors="ignore") as f:
        in_defs = True
        current_time = 0

        for raw in f:
            line = raw.strip()
            if not line:
                continue

            if in_defs:
                if line.startswith("$var"):
                    parts = line.split()
                    if len(parts) < 5:
                        continue
                    code = parts[3]
                    name = parts[4]
                    if name == MISS_NAME:
                        miss_code = code
                    elif name == CYCLE_NAME:
                        cycle_code = code
                elif line.startswith("$enddefinitions"):
                    in_defs = False
                continue

            c0 = line[0]
            if c0 == "#":
                try:
                    current_time = int(line[1:])
                except:
                    pass

            elif c0 in "01xXzZ":
                val = c0
                code = line[1:].strip()
                if code == miss_code:
                    miss_tv.append((current_time, 1 if val == "1" else 0))

            elif c0 in "bB":
                parts = line.split()
                if len(parts) == 2:
                    bin_str = parts[0][1:]
                    code = parts[1].strip()
                    if code == cycle_code:
                        try:
                            cycle_val = int(bin_str, 2)
                        except:
                            cycle_val = 0
                        cycle_tv.append((current_time, cycle_val))

    return miss_tv, cycle_tv


# ------------------------------------------------------------
# 3. Count misses in baseline / optimized regions
# ------------------------------------------------------------
def count_misses_in_regions(miss_tv, cycle_tv, start_b, end_b, start_o, end_o):
    if not cycle_tv:
        return 0, 0, 0

    idx = 0
    cycle_time, cycle_val = cycle_tv[0]

    def get_cycle_at(t):
        nonlocal idx, cycle_time, cycle_val
        while idx + 1 < len(cycle_tv) and cycle_tv[idx + 1][0] <= t:
            idx += 1
            cycle_time, cycle_val = cycle_tv[idx]
        return cycle_val

    mb = mo = mx = 0
    prev = 0

    for t, v in miss_tv:
        if prev == 0 and v == 1:  # rising edge
            c = get_cycle_at(t)
            if start_b <= c < end_b:
                mb += 1
            elif start_o <= c < end_o:
                mo += 1
            else:
                mx += 1
        prev = v

    return mb, mo, mx


# ------------------------------------------------------------
# 4. Plot latency + misses (with explicit colors)
# ------------------------------------------------------------
def plot_metrics(baseline_lat, optimized_lat, mb, mo):
    labels = ["Baseline", "Optimized"]

    fig, axes = plt.subplots(1, 2, figsize=(8, 4))

    # Left: latency (blue)
    axes[0].bar(labels, [baseline_lat, optimized_lat], color="tab:blue")
    axes[0].set_title("GEMV Latency")
    axes[0].set_ylabel("Cycles")

    # Right: misses (orange)
    axes[1].bar(labels, [mb, mo], color="tab:orange")
    axes[1].set_title("DCache Misses")
    axes[1].set_ylabel("Miss count")

    fig.suptitle("Baseline vs Optimized: Latency and Misses")
    fig.tight_layout()
    plt.show()


# ------------------------------------------------------------
# 5. Main
# ------------------------------------------------------------
def main():
    if len(sys.argv) != 3:
        print("Usage: python3 cva6_extract_metrics.py waves.vcd transcript")
        sys.exit(1)

    vcd_path = sys.argv[1]
    transcript_path = sys.argv[2]

    start_b, end_b, start_o, end_o = load_metrics_from_transcript(transcript_path)

    baseline_lat = end_b - start_b
    optimized_lat = end_o - start_o

    print("=== TIMING INFO ===")
    print(f"Baseline:  {baseline_lat} cycles")
    print(f"Optimized: {optimized_lat} cycles")

    miss_tv, cycle_tv = parse_vcd(vcd_path)

    mb, mo, mx = count_misses_in_regions(miss_tv, cycle_tv, start_b, end_b, start_o, end_o)

    print("\n=== MISS INFO ===")
    print(f"Baseline misses : {mb}")
    print(f"Optimized misses: {mo}")
    print(f"Other misses    : {mx}")

    plot_metrics(baseline_lat, optimized_lat, mb, mo)


if __name__ == "__main__":
    main()
