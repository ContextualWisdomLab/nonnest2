## 2024-07-25 - Vectorized Operations in R
**Learning:** In R codebases, using `apply(..., 1, sum)` or `apply(..., 2, mean)` on matrices is significantly slower than using the optimized, vectorized base equivalents `rowSums()` and `colMeans()`.
**Action:** Always prefer `rowSums()`, `colSums()`, `rowMeans()`, and `colMeans()` over `apply` for basic matrix summarization to ensure better performance.

## 2024-05-24 - Optimized Row-Wise String Concatenation in R
**Learning:** Using `apply(mat, 1, paste, collapse = "")` for row-wise string concatenation in R is very slow due to the loop overhead over rows in interpreted code.
**Action:** Always prefer `do.call(paste0, as.data.frame(mat))` to concatenate columns vectorized-style instead, which drastically speeds up the operation.

## 2024-05-25 - Avoid O(N^2) memory reallocation in R loops
**Learning:** Using `do.call(cbind, ...)` to grow an N-row object across K submodels causes $O(NK^2)$ cumulative copying and $O(NK)$ peak storage.
**Action:** Accumulate sums directly to keep $O(N)$ accumulator storage and $O(NK)$ total accumulation work.
## 2026-07-14 - Matrix Cross Product Optimization
**Learning:** In R, matrix multiplication of the form `t(X) %*% Y` explicitly allocates memory for the transposed matrix. Using the optimized base function `crossprod(X, Y)` avoids this allocation.
**Action:** Always replace `t(X) %*% Y` with `crossprod(X, Y)` for faster and more memory-efficient cross-product calculations.
## 2024-07-25 - Optimize ifelse in R loops
**Learning:** `ifelse()` evaluates both the `yes` and `no` expressions completely before subsetting, which is inefficient for expensive operations like `log()`.
**Action:** Preallocate a vector with identical length and type, such as `term <- Y * 0`, and use standard vector subsetting instead for a measurable speed boost.
