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

## 2024-07-28 - Add Input Validation for Exported Functions
**Vulnerability:** Exported functions like `icci` and `vuongtest` lacked input validation for arguments like `conf.level`, `nested`, and `adj`. Passing invalid arguments (e.g. non-numeric bounds or wrong types) allowed errors to propagate into arithmetic or logical evaluations, ultimately triggering unhandled internal exceptions that exposed raw contexts and structural assumptions (e.g. `$ operator is invalid for atomic vectors`).
**Learning:** Security boundaries must exist at the entry points (the exported API). Unvalidated inputs that fall through to internal logic can induce failures that disclose details of the underlying implementation.
**Prevention:** Strictly validate the type, length, and range of all inputs in exported functions before any other operations, and fail securely with a generic error using `stop(..., call. = FALSE)`.
