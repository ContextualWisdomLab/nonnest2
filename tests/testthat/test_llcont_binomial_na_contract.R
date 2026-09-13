context("binomial llcont missing-value contract")

test_that("binomial normalization preserves missing casewise contributions", {
  response <- cbind(
    success = c(NA_real_, 1, 2, 3),
    failure = c(0, 3, 2, 1)
  )
  prior_weights <- rep.int(1, nrow(response))

  fit <- structure(
    list(
      family = binomial(),
      y = response,
      prior.weights = prior_weights,
      weights = prior_weights,
      deviance = 1,
      fitted.values = c(0.2, 0.3, 0.4, 0.5)
    ),
    class = c("glm", "lm")
  )

  contributions <- llcont(fit)

  expect_true(is.na(contributions[1]))
  expect_true(all(is.finite(contributions[-1])))
})
