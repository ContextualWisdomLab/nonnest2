test_that("the cached inverses preserve Vuong equation 3.6", {
  dat <- data.frame(
    y = c(1.2, 2.4, 1.7, 4.8, 3.6, 6.1, 5.2, 7.4),
    x = c(0, 1, 0, 2, 1, 3, 2, 4),
    z = c(1, 0, 2, 1, 3, 2, 4, 3)
  )
  model_a <- lm(y ~ x, data = dat)
  model_b <- lm(y ~ z, data = dat)
  n <- nrow(dat)

  ab1 <- nonnest2:::calcAB(model_a, n, NULL, vcov)
  ab2 <- nonnest2:::calcAB(model_b, n, NULL, vcov)
  bc <- nonnest2:::calcBcross(ab1$sc, ab2$sc, n)
  expected_w <- cbind(
    rbind(
      -ab1$B %*% chol2inv(chol(ab1$A)),
      t(bc) %*% chol2inv(chol(ab1$A))
    ),
    rbind(
      -bc %*% chol2inv(chol(ab2$A)),
      ab2$B %*% chol2inv(chol(ab2$A))
    )
  )
  expected <- Re(eigen(expected_w, only.values = TRUE)$values)

  expect_equal(
    nonnest2:::calcLambda(model_a, model_b, n, NULL, NULL, vcov, vcov),
    expected
  )
})

test_that("vuongtest sanitizes singular covariance errors", {
  dat <- data.frame(y = c(1, 2, 3, 4), x = c(1, 2, 3, 4))
  model_a <- lm(y ~ x, data = dat)
  model_b <- lm(y ~ 1, data = dat)

  singular_vcov <- function(object) {
    npar <- length(coef(object))
    matrix(1, nrow = npar, ncol = npar)
  }

  err <- tryCatch(
    vuongtest(model_a, model_b, vc1 = singular_vcov, vc2 = vcov),
    error = identity
  )

  expect_s3_class(err, "error")
  expect_identical(
    conditionMessage(err),
    "Matrix inversion failed during Vuong test: matrix may not be positive definite."
  )
  expect_null(conditionCall(err))
  expect_false(
    grepl(
      "leading minor|chol|singular|computationally singular|system is exactly singular",
      conditionMessage(err)
    )
  )
})
