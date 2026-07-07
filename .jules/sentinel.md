## 2024-05-24 - [Information Leakage in R try blocks]
**Vulnerability:** The default `try()` function in R prints error messages to standard error unless explicitly silenced. If a caught error is mathematical (like matrix singularity during log-likelihood computation in dmvnorm), it leaks internal operational details.
**Learning:** Even internal mathematical operations, when catching exceptions intentionally for fallbacks, should use `silent = TRUE` to avoid polluting logs or inadvertently revealing structural data.
**Prevention:** Always append `silent = TRUE` to `try()` when the error output isn't strictly necessary for debugging, or use `tryCatch()` for more control.
