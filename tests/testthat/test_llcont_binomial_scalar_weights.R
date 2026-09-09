context("llcont binomial weight shape")

test_that("grouped binomial llcont expands scalar prior weights over all rows", {
  successes <- c(1, 0, 2)
  failures <- c(1, 0, 0)
  fit <- glm(cbind(successes, failures) ~ 1, family = binomial())

  # Exercise the scalar-weight compatibility path already handled explicitly by
  # llcont.glm while keeping a zero-trial row in the grouped response.
  fit$prior.weights <- 1
  expect_length(weights(fit), 1L)

  contributions <- llcont(fit)

  expect_length(contributions, 3L)
  expect_false(anyNA(contributions))
  expect_equal(unname(contributions[2]), 0)
})
