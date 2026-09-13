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

test_that("weighted polr contributions retain one value per fitted row", {
  .require_mass()
  fit <- MASS::polr(Sat ~ Infl + Type + Cont, data = MASS::housing, weights = Freq, Hess = TRUE)
  contributions <- llcont(fit)

  expect_length(contributions, nrow(fit$fitted.values))
  expect_equal(names(contributions), rownames(fit$fitted.values))

  y <- unclass(fit$model[[1]])
  w <- model.weights(fit$model)
  wherey <- cbind(seq_along(y), as.numeric(y))
  direct_calc <- w * log(fit$fitted.values[wherey])
  names(direct_calc) <- rownames(fit$fitted.values)
  expect_equal(as.numeric(contributions), as.numeric(direct_calc))

  expect_equal(sum(contributions), as.numeric(logLik(fit)))
})
