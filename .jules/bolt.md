## 2024-05-18 - Caching Matrix Inversions in vuongtest
**Learning:** In statistical R packages involving likelihood calculations, matrix inversion is a common performance bottleneck. Repeating the exact same inversion inside matrix bindings multiplies this cost unnecessarily.
**Action:** Always inspect matrix construction blocks for duplicated expensive operations and extract them into cached local variables before assembling the final block matrix.
