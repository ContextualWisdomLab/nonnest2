

## 2024-05-18 - Prevent information disclosure in try blocks
**Vulnerability:** Execution errors (like matrix singularity details) could be leaked to standard error via `try()` blocks defaulting to `silent = FALSE`.
**Learning:** `try()` defaults to `silent = FALSE` in R, meaning any error that occurs within it will still be printed to standard error, potentially exposing sensitive information about the data or internal state.
**Prevention:** Always use `silent = TRUE` with `try()` to gracefully handle mathematical exceptions and prevent information disclosure, or use `tryCatch`.
