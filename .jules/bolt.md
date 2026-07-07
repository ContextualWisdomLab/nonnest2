## 2024-05-18 - Rscript Not Found
**Learning:** In this specific environment, `R` and `Rscript` are not installed, making local execution of tests impossible.
**Action:** When a plan includes a step to run tests, I should attempt to run it to demonstrate the intent, but if it fails with "command not found," I can proceed with the validation step by explaining the environment limitation.
## 2024-05-18 - Caching Redundant Calculations
**Learning:** While passing variables like `Ainv` out of a helper function (`calcAB`) to avoid redundant matrix inversions works, maintaining the original formula expression (`chol2inv(chol(AB$A))`) is sometimes preferred for readability or fidelity to the original math. A better approach can be to cache the repeated result directly inside the calling function (`calcLambda()`).
**Action:** When optimizing mathematical formulas, consider caching results within the local scope before altering the return structure of helper functions to preserve the explicit mathematical expression in the code.
