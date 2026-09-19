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
## 2026-08-11 - Fast 2D Matrix Subsetting vs One-Hot Multiplication
**Learning:** In R codebases, extracting elements from a matrix using a one-hot encoded matrix multiplication (or even `rowSums(idx * matrix)`) requires $O(NK)$ space and is computationally slow. Additionally, using `as.numeric(names(y))` for indexing can lead to out-of-bounds errors if row names are non-sequential.
**Action:** Use direct 2-dimensional matrix subsetting (e.g., `matrix[cbind(seq_along(y), y)]`) to significantly improve performance, reduce memory allocation to $O(N)$ auxiliary space, and guarantee 1:N sequential indexing.
