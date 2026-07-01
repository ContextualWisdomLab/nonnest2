## 2024-05-24 - R-level apply loop bottleneck
**Learning:** Using `apply(..., 1, sum)` and `apply(..., 2, mean)` on matrices in R is significantly slower than using the equivalent vectorized C functions `rowSums()` and `colMeans()`.
**Action:** Always prefer `rowSums()`, `colSums()`, `rowMeans()`, and `colMeans()` over `apply()` for simple row/column aggregations on matrices in R codebases.
