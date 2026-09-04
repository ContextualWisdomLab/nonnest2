capture_input_error <- function(expression) {
  tryCatch(force(expression), error = identity)
}

expect_fail_closed_input <- function(error, expected_message) {
  expect_s3_class(error, "error")
  expect_identical(conditionMessage(error), expected_message)
  expect_null(conditionCall(error))
}

test_that("vuongtest rejects invalid nested values without exposing calls", {
  invalid_values <- list(logical(), c(TRUE, FALSE), NA, "yes")

  for (value in invalid_values) {
    error <- capture_input_error(vuongtest(NULL, NULL, nested = value))
    expect_fail_closed_input(
      error,
      "Argument 'nested' must be a single non-missing logical value."
    )
  }
})

test_that("vuongtest rejects invalid adjustment values without exposing calls", {
  invalid_values <- list(character(), c("aic", "bic"), NA_character_, "other", 1)

  for (value in invalid_values) {
    error <- capture_input_error(vuongtest(NULL, NULL, adj = value))
    expect_fail_closed_input(
      error,
      "Argument 'adj' must be one of \"none\", \"aic\", or \"bic\"."
    )
  }
})

test_that("icci rejects invalid confidence levels without exposing calls", {
  invalid_values <- list(
    numeric(),
    c(0.90, 0.95),
    NA_real_,
    NaN,
    Inf,
    -Inf,
    0,
    1,
    "0.95"
  )

  for (value in invalid_values) {
    error <- capture_input_error(icci(NULL, NULL, conf.level = value))
    expect_fail_closed_input(
      error,
      paste(
        "Argument 'conf.level' must be a single finite numeric value",
        "strictly between 0 and 1."
      )
    )
  }
})
