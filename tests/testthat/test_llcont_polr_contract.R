context("llcont.polr contribution contract")

test_that("llcont.polr handles unweighted and reordered observations", {
  previous_contrasts <- getOption("contrasts")
  on.exit(options(contrasts = previous_contrasts), add = TRUE)

  with_test_packages("MASS", {
    data("housing", package = "MASS")
    options(contrasts = c("contr.treatment", "contr.poly"))

    unweighted <- MASS::polr(Sat ~ Infl + Type + Cont, data = housing)
    unweighted_ll <- llcont(unweighted)

    expect_length(unweighted_ll, nrow(unweighted$model))
    expect_equal(sum(unweighted_ll), as.numeric(logLik(unweighted)))

    reversed_housing <- housing[rev(seq_len(nrow(housing))), , drop = FALSE]
    weighted <- MASS::polr(
      Sat ~ Infl + Type + Cont,
      weights = Freq,
      data = reversed_housing
    )
    response <- unclass(model.response(weighted$model))
    expected <- model.weights(weighted$model) *
      log(weighted$fitted.values[cbind(seq_along(response), response)])
    names(expected) <- names(response)

    expect_equal(llcont(weighted), expected)
    expect_equal(sum(llcont(weighted)), as.numeric(logLik(weighted)))
  })
})
