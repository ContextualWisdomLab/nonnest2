## 2024-05-18 - Caching Matrix Inversions in Vuong Test
**Learning:** Found redundant `chol2inv(chol())` calls within the `calcLambda` matrix construction block in `vuongtest.R`. Matrix inversions are $O(N^3)$, so caching them and reusing is an effective and non-intrusive optimization for matrix-heavy statistic R packages.
**Action:** When inspecting matrix operations inside block initializations or recursive calls, always check if invariant intermediate expressions like inversion or decomposition are evaluated multiple times and hoist them.
