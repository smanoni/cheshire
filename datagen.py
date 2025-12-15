import random

N = 32
OUTFILE = "sw/tests/matrix.h"

random.seed(0xDEADBEEF)   # fixed seed for reproducibility

with open(OUTFILE, "w") as f:
    f.write("#ifndef RANDOM_MATRIX_H\n#define RANDOM_MATRIX_H\n\n")
    f.write(f"#define N {N}\n\n")
    f.write("static const uint64_t A[N][N] = {\n")

    for i in range(N):
        row = []
        for j in range(N):
            val = random.getrandbits(64)
            row.append(f"0x{val:016x}ULL")
        f.write("    { " + ", ".join(row) + " },\n")

    f.write("};\n\n")
    f.write("#endif // RANDOM_MATRIX_H\n")

print(f"Generated {OUTFILE} with a {N}x{N} random matrix and N define.")
