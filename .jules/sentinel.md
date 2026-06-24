## 2026-06-24 - Input Validation Enhancement
**Vulnerability:** Missing input validation
**Learning:** R functions often lack input validation for arguments like `conf.level`, `nested`, and `adj`, which could lead to unexpected behavior or obscure errors downstream.
**Prevention:** Always validate numeric ranges, logical bounds, and enum choices using `is.numeric`, `is.logical`, and `match.arg`.
