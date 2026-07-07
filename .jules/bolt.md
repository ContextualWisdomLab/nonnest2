## 2024-05-24 - Caching over algebraic shortcuts in statistical libraries
**Learning:** In purely statistical mathematical libraries like nonnest2, performance optimizations must not implement algebraic shortcuts that break the source-level code correspondence to original mathematical formulas from referenced papers.
**Action:** Focus on safe operations like caching repeated calculations (e.g. matrix inversions `chol2inv(chol(...))`) into local variables rather than aggressive structural code changes, and preserve the formula's visual mapping.
