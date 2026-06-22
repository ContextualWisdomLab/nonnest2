## 2026-06-22 - Optimize redundant matrix inversion in R/vuongtest.R
**Learning:** Found a matrix being computed by `chol2inv(chol(tmpvc))` in `calcAB`, and then repeatedly inverted again via `chol2inv(chol(A))` in `calcLambda`. Double inversion of positive-definite symmetric matrices returns the original matrix but with substantial overhead ($O(N^3)$ operations).
**Action:** When a function requires the original covariance matrix and its inverse, pass both or use the cached original instead of calling `chol2inv` on the inverted matrix.
