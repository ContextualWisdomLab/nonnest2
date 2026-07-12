## 2024-07-25 - Vectorized Operations in R
**Learning:** In R codebases, using `apply(..., 1, sum)` or `apply(..., 2, mean)` on matrices is significantly slower than using the optimized, vectorized base equivalents `rowSums()` and `colMeans()`.
**Action:** Always prefer `rowSums()`, `colSums()`, `rowMeans()`, and `colMeans()` over `apply` for basic matrix summarization to ensure better performance.

## 2024-05-24 - Optimized Row-Wise String Concatenation in R
**Learning:** Using `apply(mat, 1, paste, collapse = "")` for row-wise string concatenation in R is very slow due to the loop overhead over rows in interpreted code.
**Action:** Always prefer `do.call(paste0, as.data.frame(mat))` to concatenate columns vectorized-style instead, which drastically speeds up the operation.
