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
