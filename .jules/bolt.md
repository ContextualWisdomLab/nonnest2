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
## 2024-05-18 - Optimize ifelse Overhead in R Log-Likelihood Evaluation
**Learning:** In R codebases, the `ifelse()` function computes both the `yes` and `no` branches unconditionally before selecting values, causing high overhead (especially in high-frequency functions like `llcont`). This issue is often amplified in loops or large vectorized arrays where subsetting alone is much more efficient.
**Action:** Replace `ifelse()` with vectorized subsetting (e.g. `res <- vector * 0; res[cond] <- ...`) when conditions act as filters or when computing one of the branches has non-negligible cost. Additionally, ensure correct scalar fallback handling (e.g., `if(length(var) == 1) var else var[cond]`) when sub-setting.
