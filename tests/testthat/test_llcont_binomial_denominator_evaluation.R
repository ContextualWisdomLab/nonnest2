context("binomial llcont denominator evaluation")

`[.division_guard_matrix` <- function(x, i, j, ..., drop = TRUE) {
  result <- NextMethod("[")
  if (!missing(j) && length(j) == 1L && identical(as.integer(j), 1L) && isTRUE(drop)) {
    class(result) <- c("division_guard_vector", class(result))
  }
  result
}

Ops.division_guard_vector <- function(e1, e2) {
  if (.Generic == "/" && any(e2 == 0, na.rm = TRUE)) {
    stop("masked zero denominator was evaluated", call. = FALSE)
  }
  NextMethod()
}

test_that("binomial normalization does not divide masked zero-total rows", {
  response <- cbind(
    success = c(0, 1, 2, 3),
    failure = c(0, 3, 2, 1)
  )
  class(response) <- c("division_guard_matrix", class(response))

  fit <- structure(
    list(
      family = binomial(),
      y = response,
      prior.weights = rep.int(1, nrow(response)),
      weights = rep.int(1, nrow(response)),
      deviance = 1,
      fitted.values = c(0.2, 0.3, 0.4, 0.5)
    ),
    class = c("glm", "lm")
  )

  expect_silent(contributions <- llcont(fit))
  expect_identical(unname(contributions[1]), 0)
})
