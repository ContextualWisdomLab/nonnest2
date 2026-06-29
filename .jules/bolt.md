## 2024-05-24 - Unnecessary Matrix Inversions

**Learning:** Mathematical operations that effectively cancel each other out (like computing the inverse of an inverse matrix) can significantly degrade performance in statistical libraries due to $O(K^3)$ matrix inversion complexity.

**Action:** Whenever identifying an inversion function (`chol2inv`, `solve`, etc.) being passed between functions, look for where the original matrix might already contain the solution, and pass the required state directly to avoid redundant inversions.
