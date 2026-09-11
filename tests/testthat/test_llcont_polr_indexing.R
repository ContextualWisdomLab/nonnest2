test_that("polr contributions use row position rather than response names", {
  with_test_packages("MASS", {
    dat <- housing
    row.names(dat) <- paste0("case-", seq_len(nrow(dat)))

    fit <- polr(Sat ~ Infl + Type + Cont, weights = Freq, data = dat)
    contributions <- llcont(fit)

    expect_length(contributions, nrow(model.frame(fit)))
    expect_equal(sum(contributions), as.numeric(logLik(fit)), tolerance = 1e-8)
  })
})
