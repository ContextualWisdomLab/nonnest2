## 2024-07-08 - Fast Row and Column Aggregation in R
**Learning:** In R, using `apply()` with `sum` or `mean` over dimensions (e.g., `apply(..., 1, sum)` or `apply(..., 2, mean)`) is inefficient because it iterates over the dimensions at the interpreted R level. The base R functions `rowSums()`, `colMeans()`, `rowMeans()`, and `colSums()` are implemented in highly optimized internal C code and are significantly faster.
**Action:** Always prefer `rowSums()`, `colMeans()`, `rowMeans()`, and `colSums()` over `apply()` when aggregating over matrix or data frame dimensions.
