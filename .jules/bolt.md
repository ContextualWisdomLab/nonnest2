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
## 2026-10-04 - R ifelse evaluation in binomial/glm likelihoods
**Learning:** `ifelse(cond, yes, no)` evaluates both the `yes` and `no` branches completely before subsetting. In large models like `glm(family=binomial)` evaluated by `llcont`, this results in significant performance overhead (and sometimes unintended division-by-zero operations that would otherwise be masked by `ifelse`). Intermediate division by zero in R yields `Inf`/`NaN` which is safe as long as they are properly overwritten using vectorized subsetting afterwards.
**Action:** Replace `ifelse()` with vectorized subsetting with explicit NA handling (e.g. `tmp[!is.na(cond) & cond] <- 0`) for large arrays. Pre-allocate using a variable that matches the length of the condition vector.
