## 2024-05-23 - Information Leakage in try() Blocks
**Vulnerability:** Found a `try()` block without `silent=TRUE` in `R/llcont.R`, which could potentially leak sensitive internal state or stack traces to the user via error messages.
**Learning:** In R, `try()` by default prints the error message to the console/stderr. In a web or API context, this might inadvertently expose system details or data.
**Prevention:** Always use `silent=TRUE` when using `try()` if the error is caught and handled programmatically and the raw error message is not intended for the end-user.
