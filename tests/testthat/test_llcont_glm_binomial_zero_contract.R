test_that("glm binomial zero totals and zero prior weights preserve likelihood contributions", {
  observed <- data.frame(
    success = c(0, 1, 2, 3, 1, 4, 2),
    failure = c(0, 4, 3, 2, 4, 1, 3),
    x = 0:6,
    prior_weight = c(1, 1, 1, 0, 1, 1, 1)
  )

  fit <- glm(
    cbind(success, failure) ~ x,
    data = observed,
    family = binomial(),
    weights = prior_weight
  )
  contributions <- llcont(fit)

  expect_true(all(is.finite(contributions)))
  expect_equal(contributions[c(1, 4)], c(0, 0))
  expect_equal(sum(contributions), as.numeric(logLik(fit)))
})
