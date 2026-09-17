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
## 2024-05-15 - [R Performance: ifelse Overhead]
**Learning:** In R, ifelse evaluates both true and false branches entirely before subsetting, which is very inefficient for vector operations.
**Action:** Optimize this by preallocating with res <- Y * 0 to preserve attributes and using vectorized subsetting like if any cond res subset <- ...
## 2026-08-11 - Matrix 2D Subsetting vs Dummy Matrices
**Learning:** In R, extracting specific elements from a matrix based on row-wise category indices by allocating a one-hot dummy matrix and taking `rowSums` of the element-wise product allocates an $N \times K$ matrix, requiring $O(NK)$ space and operations. This is very slow for large datasets. Furthermore, if row names are non-sequential, mapping via `as.numeric(names(y))` can cause out-of-bounds subsetting crashes.
**Action:** Always prefer direct two-dimensional matrix subsetting (e.g., `fitted_values[cbind(seq_along(y), y)]`) to extract the elements in $O(N)$ space and time without allocating any dummy structures. Additionally, always use `seq_along` rather than `names` to safely guarantee sequential row mapping.
