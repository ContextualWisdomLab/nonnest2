context("llcont binomial normalization contract")

test_that("matrix-response zero totals preserve glm log-likelihood", {
  successes <- c(0, 1, 2, 3, 1)
  failures <- c(0, 2, 1, 0, 3)
  predictor <- seq_along(successes)
  response <- cbind(successes, failures)

  fit <- glm(response ~ predictor, family = binomial())
  fit$y <- response

  contributions <- llcont(fit)

  expect_false(any(is.nan(contributions)))
  expect_equal(sum(contributions), as.numeric(logLik(fit)))
})

test_that("zero prior weights remain zero-contribution observations", {
  response <- c(0, 1, 0, 1, 1, 0)
  predictor <- seq_along(response)
  prior_weight <- c(0, 1, 1, 1, 1, 1)

  fit <- glm(
    response ~ predictor,
    family = binomial(),
    weights = prior_weight
  )

  contributions <- llcont(fit)

  expect_identical(unname(contributions[1]), 0)
  expect_equal(sum(contributions), as.numeric(logLik(fit)))
})
