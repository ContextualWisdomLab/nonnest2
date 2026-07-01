
## 2024-05-24 - Silence R try() calls
**Vulnerability:** Information Disclosure (Leaking stack traces/internal mathematical exceptions)
**Learning:** In R, the `try()` function defaults to `silent = FALSE`. When used without explicit silencing, any exceptions or errors from the internal code block (like matrix singularity errors from `dmvnorm`) will be printed to stderr, leaking internal application state to logs or the console.
**Prevention:** Always use `try(..., silent = TRUE)` or use `tryCatch` to gracefully handle errors without inadvertently logging them.
