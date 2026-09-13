context("binomial llcont casewise regression")

test_that("binomial matrix responses preserve casewise likelihood contributions", {
  response <- cbind(
    success = c(0, 1, 2, 0, 3),
    failure = c(0, 3, 2, 4, 1)
  )
  prior_weights <- c(2, 1, 3, 4, 5)
  fitted_probabilities <- c(0.2, 0.3, 0.4, 0.5, 0.6)

  fit <- structure(
    list(
      family = binomial(),
      y = response,
      prior.weights = prior_weights,
      weights = rep.int(1, nrow(response)),
      deviance = 1,
      fitted.values = fitted_probabilities
    ),
    class = c("glm", "lm")
  )

  totals <- rowSums(response)
  proportions <- ifelse(totals == 0, 0, response[, 1] / totals)
  trials <- if (any(totals > 1)) totals else prior_weights
  likelihood_weights <- ifelse(trials > 0, prior_weights / trials, 0)
  expected <- dbinom(
    round(trials * proportions),
    round(trials),
    fitted_probabilities,
    log = TRUE
  ) * likelihood_weights

  actual <- llcont(fit)

  expect_equal(actual, expected)
  expect_equal(actual[totals == 0], 0)
})
