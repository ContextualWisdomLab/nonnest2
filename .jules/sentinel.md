## 2024-05-23 - Prevent information disclosure in try block
**Vulnerability:** Information Disclosure
**Learning:** R's `try()` blocks default to `silent = FALSE` and can inadvertently leak internal execution errors (e.g., matrix singularity details) to standard error.
**Prevention:** Always use `try(..., silent = TRUE)` or `tryCatch` when handling mathematical exceptions in R.
