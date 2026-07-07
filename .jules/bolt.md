## 2024-05-24 - Unnecessary Matrix Inversions

**Learning:** Mathematical operations that effectively cancel each other out (like computing the inverse of an inverse matrix) can significantly degrade performance in statistical libraries due to $O(K^3)$ matrix inversion complexity.

**Action:** Whenever identifying an inversion function (`chol2inv`, `solve`, etc.) being passed between functions, look for where the original matrix might already contain the solution, and pass the required state directly to avoid redundant inversions.

## 2024-05-24 - Optimization rejected due to breaking paper correspondence

**Learning:** An optimization that breaks the source-level correspondence to the original paper formula (Vuong Eq. 2.1 and 2.2) in `calcAB` was rejected. Even if an algebraic shortcut improves performance by avoiding matrix inversions, preserving the documented mathematical equations is more important for code readability and scientific correctness.

**Action:** Avoid removing explicit computations that directly correspond to formulas from the original papers referenced in statistical packages, even if they can be optimized away through algebraic shortcuts. Instead, look for optimizations that don't alter the core mathematical definitions, such as caching repeated calculations (e.g., caching `chol2inv(chol(A))` when used multiple times).
