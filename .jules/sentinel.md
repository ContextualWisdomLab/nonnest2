## 2024-07-03 - [Prevent Information Leakage in R try() Blocks]
**Vulnerability:** R's `try()` defaults to `silent = FALSE`, which can leak mathematical exception details (e.g., matrix singularity) to standard error, potentially disclosing internal state or data structure.
**Learning:** In statistical libraries, implicitly relying on `try-error` classes without explicitly silencing `try()` calls is a subtle but real information disclosure risk.
**Prevention:** Always use `try(..., silent = TRUE)` or `tryCatch` to gracefully handle mathematical exceptions and prevent error leakage.
