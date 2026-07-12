test_that("singular covariance errors are sanitized", {
  dat <- data.frame(y = c(1, 2, 3, 4), x = c(1, 2, 3, 4))
  model_a <- lm(y ~ x, data = dat)
  model_b <- lm(y ~ 1, data = dat)

  singular_vcov <- function(object) {
    npar <- length(coef(object))
    matrix(1, nrow = npar, ncol = npar)
  }

  err <- tryCatch(
    vuongtest(model_a, model_b, vc1 = singular_vcov, vc2 = vcov),
    error = conditionMessage
  )

  expect_identical(
    err,
    "Matrix inversion failed during Vuong test: matrix may not be positive definite."
  )
  expect_false(grepl("leading minor|chol|singular|computationally singular|system is exactly singular", err))
})
