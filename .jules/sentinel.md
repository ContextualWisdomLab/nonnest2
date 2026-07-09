## 2024-05-18 - Math Exceptions Leaking Internals
**Vulnerability:** `try()` default `silent = FALSE` leaks math exception details to standard error.
**Learning:** Default behavior of R's `try()` leaks information.
**Prevention:** Use `try(..., silent = TRUE)` explicitly to suppress stderr output from math exceptions.
