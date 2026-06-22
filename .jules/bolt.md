## 2024-06-22 - Replacing apply with colMeans/rowSums
**Learning:** R's `apply()` function when used over margins to calculate sums and means converts data internally to a list and loops over margins inside R, which causes a significant performance hit on matrix operations. R has highly optimized C-level functions like `rowSums` and `colMeans` to perform exactly the same function drastically faster.
**Action:** Always refactor occurrences of `apply(..., 1, sum)` or `apply(..., 2, mean)` to `rowSums()` and `colMeans()` respectively.
