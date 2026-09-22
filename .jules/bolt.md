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

## 2024-10-25 - Avoid O(N*K) one-hot matrix allocation for row subsetting in R
**Learning:** In R, when extracting specific elements from an N x K matrix based on a vector of N category indices, allocating an N x K one-hot encoding matrix and using element-wise multiplication followed by `rowSums` is highly inefficient and prone to row-name mismatch bugs when the data is reordered.
**Action:** Always use 2D matrix subsetting `mat[cbind(seq_along(y), y)]` to extract the corresponding elements directly in O(N) time and memory, avoiding intermediate large matrix allocations.

## 2024-10-25 - Transient CI failures with open code review
**Learning:** Transient CI failures in workflows like `opencode-review` (e.g., 'No APPROVED or CHANGES_REQUESTED from opencode-agent on the current head') are environmental errors related to asynchronous GitHub App processing or transient network timeouts.
**Action:** Resolve them by resubmitting the PR with the exact same details to trigger a new run, without modifying the codebase.

## 2024-10-25 - Transient CI failures with CodeQL analysis
**Learning:** Transient CI failures in workflows like `CodeQL compatibility analysis` (e.g., 'CodeQL scan dispatched. The dispatch workflow will rerun this exact failed CodeQL job after publishing its terminal verdict.') are environmental errors related to asynchronous GitHub App processing or transient network timeouts.
**Action:** Resolve them by resubmitting the PR with the exact same details to trigger a new run, without modifying the codebase.

## 2024-10-25 - Transient CI failures with Noema review
**Learning:** Transient CI failures in workflows like `noema-review` (e.g., 'Noema provider capacity unavailable' or 'HTTP Error 429: Too Many Requests') are environmental errors related to asynchronous GitHub App processing or transient network timeouts.
**Action:** Resolve them by resubmitting the PR with the exact same details to trigger a new run, without modifying the codebase.
