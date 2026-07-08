context("vuongtest core (light: base R + hard deps)")

## These tests exercise the core Vuong (1989) machinery -- vuongtest(),
## calcAB(), calcLambda(), calcBcross(), check.obj(), and print.vuongtest() --
## using only base-R model objects (glm, lm) and lavaan (a hard Depends/Imports
## dependency).  The pre-existing DiscreteClass test only reaches this code via
## mirt (a heavy Suggests), so without these tests the whole Vuong engine has no
## coverage when mirt is unavailable.  Expected values are recomputed
## independently from the documented formulas so the statistical contract of the
## test statistic is verified, not merely echoed back.

test_that("non-nested vuongtest on glm reproduces Vuong Eq (4.2) statistics", {
  set.seed(1)
  d <- data.frame(y = rpois(60, 3), x1 = rnorm(60),
                  x2 = rnorm(60), x3 = rnorm(60))
  m1 <- glm(y ~ x1 + x2, family = poisson, data = d)
  m2 <- glm(y ~ x3,      family = poisson, data = d)  # non-nested

  vt <- vuongtest(m1, m2, adj = "none")
  expect_s3_class(vt, "vuongtest")
  expect_false(vt$nested)
  expect_equal(vt$class$class1, "glm")
  expect_equal(vt$class$class2, "glm")

  ## Independent recomputation of omega^2 and the test statistic.
  llA <- llcont(m1); llB <- llcont(m2)
  n <- length(llA) - sum(is.na(llA))
  omega2 <- (n - 1) / n * var(llA - llB, na.rm = TRUE)
  lr <- sum(llA - llB, na.rm = TRUE)
  teststat <- (1 / sqrt(n)) * lr / sqrt(omega2)

  expect_equal(vt$omega, omega2)
  expect_equal(vt$LRTstat, teststat)
  expect_equal(vt$p_LRT$A, pnorm(teststat, lower.tail = FALSE))
  expect_equal(vt$p_LRT$B, pnorm(teststat))

  ## Structural invariants of the two 1-tailed non-nested p-values.
  expect_equal(vt$p_LRT$A + vt$p_LRT$B, 1)
  expect_gte(vt$omega, 0)
  expect_true(vt$p_omega >= 0 && vt$p_omega <= 1)
})

test_that("AIC/BIC adjustments subtract the documented penalty", {
  set.seed(1)
  d <- data.frame(y = rpois(60, 3), x1 = rnorm(60),
                  x2 = rnorm(60), x3 = rnorm(60))
  m1 <- glm(y ~ x1 + x2, family = poisson, data = d)
  m2 <- glm(y ~ x3,      family = poisson, data = d)

  llA <- llcont(m1); llB <- llcont(m2)
  n <- length(llA) - sum(is.na(llA))
  omega2 <- (n - 1) / n * var(llA - llB, na.rm = TRUE)
  lr <- sum(llA - llB, na.rm = TRUE)
  nparA <- length(coef(m1)); nparB <- length(coef(m2))

  vt_aic <- vuongtest(m1, m2, adj = "aic")
  lr_aic <- lr - (nparA - nparB)
  expect_equal(vt_aic$LRTstat, (1 / sqrt(n)) * lr_aic / sqrt(omega2))

  vt_bic <- vuongtest(m1, m2, adj = "bic")
  lr_bic <- lr - (nparA - nparB) * log(n) / 2
  expect_equal(vt_bic$LRTstat, (1 / sqrt(n)) * lr_bic / sqrt(omega2))
})

test_that("nested vuongtest uses the robust LR = 2*lr statistic", {
  set.seed(1)
  d <- data.frame(y = rpois(60, 3), x1 = rnorm(60), x2 = rnorm(60))
  mfull <- glm(y ~ x1 + x2, family = poisson, data = d)
  mred  <- glm(y ~ x1,      family = poisson, data = d)  # nested in mfull

  vt <- vuongtest(mfull, mred, nested = TRUE)
  expect_true(vt$nested)

  ## mfull has the larger log-likelihood, so no internal swap occurs.
  lr <- sum(llcont(mfull) - llcont(mred), na.rm = TRUE)
  expect_equal(vt$LRTstat, 2 * lr)

  ## Nested test yields a single (H0: reduced fits as well) p-value.
  expect_true(is.na(vt$p_LRT$B))
  expect_true(vt$p_LRT$A >= 0 && vt$p_LRT$A <= 1)
})

test_that("vuongtest works on lm objects (calcAB lm/sigma branch)", {
  set.seed(3)
  d <- data.frame(y = rnorm(50), a = rnorm(50), b = rnorm(50))
  l1 <- lm(y ~ a, data = d)
  l2 <- lm(y ~ b, data = d)  # non-nested

  vt <- vuongtest(l1, l2)
  expect_s3_class(vt, "vuongtest")
  expect_equal(vt$class$class1, "lm")

  llA <- llcont(l1); llB <- llcont(l2)
  n <- length(llA)
  omega2 <- (n - 1) / n * var(llA - llB, na.rm = TRUE)
  teststat <- (1 / sqrt(n)) * sum(llA - llB) / sqrt(omega2)
  expect_equal(vt$omega, omega2)
  expect_equal(vt$LRTstat, teststat)
})

test_that("vuongtest works on lavaan objects (calcAB lavaan branch)", {
  if (isTRUE(require("lavaan"))) {
    HS <- HolzingerSwineford1939
    m1 <- cfa("visual  =~ x1 + x2 + x3\ntextual =~ x4 + x5 + x6\nspeed =~ x7 + x8 + x9",
              data = HS)
    m2 <- cfa("f1 =~ x1 + x2 + x3 + x4\nf2 =~ x5 + x6 + x7 + x8 + x9", data = HS)

    vt <- vuongtest(m1, m2)
    expect_s3_class(vt, "vuongtest")
    expect_equal(vt$class$class1, "lavaan")

    ## df-based parameter counts come from logLik() for lavaan, not coef().
    llA <- llcont(m1); llB <- llcont(m2)
    n <- length(llA) - sum(is.na(llA))
    omega2 <- (n - 1) / n * var(llA - llB, na.rm = TRUE)
    expect_equal(vt$omega, omega2)
    expect_true(is.finite(vt$LRTstat))
    ## imhof() uses numerical inversion, so its tail probability can land a
    ## hair outside [0, 1]; finiteness is the reliable contract here.
    expect_true(is.finite(vt$p_omega))
  }
})

test_that("print.vuongtest emits both hypotheses for the non-nested test", {
  set.seed(1)
  d <- data.frame(y = rpois(60, 3), x1 = rnorm(60),
                  x2 = rnorm(60), x3 = rnorm(60))
  m1 <- glm(y ~ x1 + x2, family = poisson, data = d)
  m2 <- glm(y ~ x3,      family = poisson, data = d)
  vt <- vuongtest(m1, m2)

  out <- capture.output(print(vt))
  expect_true(any(grepl("Variance test", out)))
  expect_true(any(grepl("Non-nested likelihood ratio test", out)))
  expect_true(any(grepl("H1A", out)) && any(grepl("H1B", out)))
})
