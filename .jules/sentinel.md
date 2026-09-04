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
## 2026-08-11 - Enforce secure error boundaries by validating input types early

**Vulnerability:**
Exported functions like `vuongtest` and `icci` expect scalar, non-missing control values. Zero-length, non-scalar, missing, non-finite, or out-of-domain values could bypass incomplete guards and fail later inside model dispatch or control flow. Those raw failures exposed internal calls instead of the public validation contract.

**Learning:**
In R, checking only `length(x) > 1` does not reject zero-length values, and numeric type checks do not reject `NA`, `NaN`, or infinities. `match.arg()` also owns its error condition, so it cannot guarantee this package's call-free public error contract.

**Prevention:**
Validate exact scalar length, type, missingness, finiteness, bounds, and enum membership before model dispatch. Raise package-owned messages with `stop(..., call. = FALSE)`, and cover zero-length, non-scalar, missing, non-finite, wrong-type, and out-of-domain inputs in `testthat`.
```R
if (length(nested) != 1L || !is.logical(nested) || is.na(nested)) {
    stop(
        "Argument 'nested' must be a single non-missing logical value.",
        call. = FALSE
    )
}
```
