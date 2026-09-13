test_that("polr llcont indexes fitted rows independently of model row names", {
  with_test_packages("MASS", {
    named_housing <- housing
    rownames(named_housing) <- sprintf("case-%03d", seq_len(nrow(named_housing)))

    fit <- polr(
      Sat ~ Infl + Type + Cont,
      weights = Freq,
      data = named_housing
    )

    contributions <- llcont(fit)

    expect_length(contributions, nrow(fit$model))
    expect_equal(sum(contributions), as.numeric(logLik(fit)))
  })
})
