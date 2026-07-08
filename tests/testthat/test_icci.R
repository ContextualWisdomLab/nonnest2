context("icci core (light: base R + hard deps)")

## Exercises icci() -- the AIC/BIC confidence-interval machinery -- and
## print.icci() using base-R (glm/lm) and lavaan model objects.  Like the Vuong
## engine, this code path is otherwise only reached through the mirt-guarded
## DiscreteClass test, so it is uncovered whenever the heavy mirt Suggests is
## absent.  Interval endpoints are recomputed from the documented normal-theory
## formula so the statistical contract is verified independently.

test_that("icci on glm reproduces the AIC/BIC confidence-interval formula", {
  set.seed(1)
  d <- data.frame(y = rpois(60, 3), x1 = rnorm(60),
                  x2 = rnorm(60), x3 = rnorm(60))
  m1 <- glm(y ~ x1 + x2, family = poisson, data = d)
  m2 <- glm(y ~ x3,      family = poisson, data = d)

  ic <- icci(m1, m2, conf.level = 0.95)
  expect_s3_class(ic, "icci")

  ## Recompute the pieces used inside icci().
  llA <- llcont(m1); llB <- llcont(m2)
  n <- length(llA) - sum(is.na(llA))
  omega2 <- (n - 1) / n * var(llA - llB, na.rm = TRUE)

  aicA <- AIC(m1); aicB <- AIC(m2)
  bicA <- AIC(m1, k = log(length(llA)))
  bicB <- AIC(m2, k = log(length(llB)))

  expect_equal(ic$AIC$AIC1, aicA)
  expect_equal(ic$AIC$AIC2, aicB)
  expect_equal(ic$BIC$BIC1, bicA)
  expect_equal(ic$BIC$BIC2, bicB)

  alpha <- 1 - 0.95
  aic_ci <- (aicA - aicB) + qnorm(c(alpha / 2, 1 - alpha / 2)) *
              sqrt(n * 4 * omega2)
  bic_ci <- (bicA - bicB) + qnorm(c(alpha / 2, 1 - alpha / 2)) *
              sqrt(n * 4 * omega2)

  expect_equal(ic$AICci, aic_ci)
  expect_equal(ic$BICci, bic_ci)

  ## The interval must be centred on the point difference and be ordered.
  expect_equal(mean(ic$AICci), aicA - aicB)
  expect_lt(ic$AICci[1], ic$AICci[2])
  expect_equal(ic$confLevel, 0.95)
})

test_that("icci confidence level widens the interval", {
  set.seed(1)
  d <- data.frame(y = rpois(60, 3), x1 = rnorm(60),
                  x2 = rnorm(60), x3 = rnorm(60))
  m1 <- glm(y ~ x1 + x2, family = poisson, data = d)
  m2 <- glm(y ~ x3,      family = poisson, data = d)

  ic95 <- icci(m1, m2, conf.level = 0.95)
  ic99 <- icci(m1, m2, conf.level = 0.99)

  ## A higher confidence level produces a strictly wider interval about the
  ## same centre.
  expect_equal(mean(ic95$AICci), mean(ic99$AICci))
  expect_gt(diff(ic99$AICci), diff(ic95$AICci))
})

test_that("icci works on lavaan objects", {
  if (isTRUE(require("lavaan"))) {
    HS <- HolzingerSwineford1939
    m1 <- cfa("visual  =~ x1 + x2 + x3\ntextual =~ x4 + x5 + x6\nspeed =~ x7 + x8 + x9",
              data = HS)
    m2 <- cfa("f1 =~ x1 + x2 + x3 + x4\nf2 =~ x5 + x6 + x7 + x8 + x9", data = HS)

    ic <- icci(m1, m2)
    expect_s3_class(ic, "icci")
    expect_equal(ic$AIC$AIC1, AIC(m1))
    expect_true(is.finite(ic$BICci[1]) && is.finite(ic$BICci[2]))
    expect_lt(ic$AICci[1], ic$AICci[2])
  }
})

test_that("print.icci reports both AIC and BIC intervals", {
  set.seed(1)
  d <- data.frame(y = rpois(60, 3), x1 = rnorm(60),
                  x2 = rnorm(60), x3 = rnorm(60))
  m1 <- glm(y ~ x1 + x2, family = poisson, data = d)
  m2 <- glm(y ~ x3,      family = poisson, data = d)
  ic <- icci(m1, m2)

  out <- capture.output(print(ic))
  expect_true(any(grepl("Confidence Interval of AIC difference", out)))
  expect_true(any(grepl("Confidence Interval of BIC difference", out)))
})
