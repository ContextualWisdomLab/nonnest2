## 2024-06-23 - Removed redundant matrix inversions
**Learning:** Found redundant double inversions of variance-covariance matrices in `vuongtest.R` where `A = chol2inv(chol(tmpvc))` was calculated, and then later `chol2inv(chol(A))` was used, essentially computing `tmpvc` again.
**Action:** Always check if a variable holding a matrix inverse is inverted again downstream, and refactor to pass the original un-inverted matrix instead to save computation time.
