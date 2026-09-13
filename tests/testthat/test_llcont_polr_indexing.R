context("llcont.polr indexing")


.require_mass <- function() {
  if (!requireNamespace("MASS", quietly = TRUE)) {
    skip("MASS is required for polr regression coverage")
  }
}


test_that("unweighted polr contributions retain one value per fitted row", {
  .require_mass()
  fit <- MASS::polr(Sat ~ Infl + Type + Cont, data = MASS::housing, Hess = TRUE)
  contributions <- llcont(fit)

  expect_length(contributions, nrow(fit$fitted.values))
  expect_equal(names(contributions), rownames(fit$fitted.values))
  expect_equal(sum(contributions), as.numeric(logLik(fit)))
})


test_that("weighted polr contributions preserve model weights", {
  .require_mass()
  fit <- MASS::polr(
    Sat ~ Infl + Type + Cont,
    data = MASS::housing,
    weights = Freq,
    Hess = TRUE
  )
  response_codes <- as.numeric(unclass(model.response(fit$model)))
  expected <- model.weights(fit$model) * log(
    fit$fitted.values[cbind(seq_along(response_codes), response_codes)]
  )
  contributions <- llcont(fit)

  expect_length(contributions, nrow(fit$fitted.values))
  expect_equal(names(contributions), rownames(fit$fitted.values))
  expect_equal(unname(contributions), unname(expected))
  expect_equal(sum(contributions), as.numeric(logLik(fit)))
})


test_that("polr fitted probabilities are independent of row-name labels", {
  .require_mass()
  labelled_housing <- MASS::housing
  rownames(labelled_housing) <- sprintf("case-%03d", seq_len(nrow(labelled_housing)))
  fit <- MASS::polr(
    Sat ~ Infl + Type + Cont,
    data = labelled_housing,
    weights = Freq,
    Hess = TRUE
  )
  response_codes <- as.numeric(unclass(model.response(fit$model)))
  expected <- model.weights(fit$model) * log(
    fit$fitted.values[cbind(seq_along(response_codes), response_codes)]
  )
  contributions <- llcont(fit)

  expect_length(contributions, nrow(fit$fitted.values))
  expect_equal(names(contributions), rownames(fit$fitted.values))
  expect_equal(unname(contributions), unname(expected))
  expect_equal(sum(contributions), as.numeric(logLik(fit)))
})


test_that("polr direct indexing uses fitted-row position after subsetting", {
  .require_mass()
  retained <- setdiff(seq_len(nrow(MASS::housing)), c(2L, 5L, 8L))
  fit <- MASS::polr(
    Sat ~ Infl + Type + Cont,
    data = MASS::housing[retained, , drop = FALSE],
    Hess = TRUE
  )
  response_codes <- as.numeric(unclass(model.response(fit$model)))
  expected <- log(
    fit$fitted.values[cbind(seq_along(response_codes), response_codes)]
  )

  expect_equal(unname(llcont(fit)), unname(expected))
  expect_equal(sum(llcont(fit)), as.numeric(logLik(fit)))
})


test_that("zero-weight impossible categories contribute zero instead of NaN", {
  response <- ordered(c("low", "high"), levels = c("low", "high"))
  model <- stats::model.frame(
    response ~ 1,
    data = data.frame(response = response),
    weights = c(0, 1)
  )
  fitted_values <- matrix(
    c(0, 1, 0.25, 0.75),
    nrow = 2,
    byrow = TRUE,
    dimnames = list(c("zero-weight", "positive-weight"), c("low", "high"))
  )
  fit <- structure(
    list(model = model, fitted.values = fitted_values, lev = levels(response)),
    class = "polr"
  )

  contributions <- llcont(fit)

  expect_false(anyNA(contributions))
  expect_equal(unname(contributions), c(0, log(0.75)))
})
