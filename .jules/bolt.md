## 2024-05-17 - Avoid Redundant Matrix Inversions

**Learning:** In statistical code where the inverse of a matrix is calculated and returned alongside other values, downstream functions may inadvertently re-calculate the inverse of that inverse matrix, resulting in unnecessary $O(p^3)$ operations. This is especially true when caching the original matrix before inversion can eliminate these redundant calculations completely.

**Action:** When inspecting mathematical logic involving Cholesky decompositions or matrix inversions, check if the inverse of the inverse is ever computed. Cache and reuse the original matrix directly to save significant processing time without sacrificing readability.
