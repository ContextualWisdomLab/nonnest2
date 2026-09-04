## 2024-05-24 - Fix Information Disclosure in try()
**Vulnerability:** `try()` block in `llcont.R` defaulted to `silent = FALSE`, inadvertently leaking internal execution errors (e.g., matrix singularity details) to standard error.
**Learning:** R's `try()` defaults to printing errors unless `silent = TRUE` is explicitly provided.
**Prevention:** Always use `silent = TRUE` inside `try()` blocks or prefer `tryCatch()` to gracefully handle exceptions and prevent information disclosure.

## 2024-05-25 - Fix Information Disclosure in error handling
**Vulnerability:** Error handling in vuongtest used stop with the raw error object, which can expose internal execution details and call stacks.
**Learning:** Re-throwing errors directly propagates the entire condition object including the call, which can leak internal arguments and stack trace details.
**Prevention:** Always use stop with call. = FALSE and a custom generic message to prevent information disclosure.

## 2024-07-13 - Prevent Information Disclosure in all stop/warning calls
**Vulnerability:** Raw `stop()` and `warning()` calls without `call. = FALSE` in `llcont.R` and `vuongtest.R` exposed execution stack/call details when raised.
**Learning:** While some instances of `stop()` inside `tryCatch()` were previously fixed to hide the call stack, other standalone exceptions and warnings still leaked call context. Security must be consistently applied across the entire codebase.
**Prevention:** Always set `call. = FALSE` when using `stop()` or `warning()` to enforce a secure-by-default boundary and prevent internal execution paths from being disclosed to the end user.
## 2024-10-31 - [Medium] Add input validation to exported functions to fail securely
**Vulnerability:** Missing strict type, length, and bounds checking on user-supplied arguments (`adj` in `vuongtest` and `conf.level` in `icci`) allowed unvalidated inputs to propagate into internal R evaluation, potentially causing unexpected raw execution errors and exposing internal context (stack traces).
**Learning:** R's default lazy evaluation and dynamic typing mean that unvalidated user inputs might evaluate deep inside package logic, bypassing intended top-level safeguards and leaking internal execution context upon failure.
**Prevention:** Always strictly validate the type, length, and bounds of user inputs at the very beginning of exported functions and fail securely using `stop(..., call. = FALSE)`. Ensure `is.na()` is explicitly checked before relational operators to avoid fatal 'missing value where TRUE/FALSE needed' errors.
