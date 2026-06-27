## 2024-05-24 - Redundant Matrix Inversions in Statistical Operations
**Learning:** Inverting a matrix and then inverting it again is a redundant O(N^3) operation that causes a massive performance bottleneck and potential precision loss. In `nonnest2`, the code computed `A <- chol2inv(chol(tmpvc))` and then later computed `chol2inv(chol(A))` to get back the original matrix `tmpvc`.
**Action:** When reviewing statistical/mathematical code, trace the lifecycle of expensive matrices to find opportunities to pass pre-computed forms rather than recalculating inverses or Cholesky decompositions.
