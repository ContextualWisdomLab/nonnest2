## 2024-05-31 - Silent Error Handling in R
**Vulnerability:** Information leakage through uncaught or default error handling in R `try()` statements.
**Learning:** In R, `try()` automatically prints error messages to standard error unless `silent = TRUE` is passed. This can leak internal execution errors, paths, or variables.
**Prevention:** Always use `try(expr, silent = TRUE)` or `tryCatch()` to gracefully handle exceptions and prevent information disclosure in error logs.
