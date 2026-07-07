context("targeted coverage")

fitted.clm <- function(object, ...) object$mpreds
model.frame.clm <- function(formula, ...) formula$mf
logLik.clm <- function(object, ...) object$ll

model.matrix.hurdle <- function(object, model, ...) {
  if (identical(model, "count")) object$X else object$Z
}
weights.hurdle <- function(object, ...) object$weights

model.matrix.zeroinfl <- function(object, model, ...) {
  if (identical(model, "count")) object$X else object$Z
}
weights.zeroinfl <- function(object, ...) object$weights

fitted.mlogit <- function(object, ...) object$prob
logLik.vglm <- function(object, summation = TRUE, ...) {
  if (summation) sum(object$ll) else object$ll
}

coef.coverage_model <- function(object, ...) object$coef
vcov.coverage_model <- function(object, ...) object$vc
logLik.coverage_model <- function(object, ...) {
  structure(sum(object$ll), df = length(object$coef), class = "logLik")
}
estfun.coverage_model <- function(x, ...) x$score

registerS3method("fitted", "clm", fitted.clm, envir = asNamespace("stats"))
registerS3method("model.frame", "clm", model.frame.clm, envir = asNamespace("stats"))
registerS3method("logLik", "clm", logLik.clm, envir = asNamespace("stats"))
registerS3method("model.matrix", "hurdle", model.matrix.hurdle, envir = asNamespace("stats"))
registerS3method("weights", "hurdle", weights.hurdle, envir = asNamespace("stats"))
registerS3method("model.matrix", "zeroinfl", model.matrix.zeroinfl, envir = asNamespace("stats"))
registerS3method("weights", "zeroinfl", weights.zeroinfl, envir = asNamespace("stats"))
registerS3method("fitted", "mlogit", fitted.mlogit, envir = asNamespace("stats"))
registerS3method("logLik", "vglm", logLik.vglm, envir = asNamespace("stats"))
registerS3method("coef", "coverage_model", coef.coverage_model, envir = asNamespace("stats"))
registerS3method("vcov", "coverage_model", vcov.coverage_model, envir = asNamespace("stats"))
registerS3method("logLik", "coverage_model", logLik.coverage_model, envir = asNamespace("stats"))
registerS3method("estfun", "coverage_model", estfun.coverage_model, envir = asNamespace("sandwich"))

make_coverage_model <- function(ll, coef = c(a = 0.2), score = NULL, call = quote(model())) {
  n <- length(ll)
  if (is.null(score)) {
    score <- matrix(seq_len(n), ncol = 1)
  }
  structure(
    list(call = call, ll = ll, coef = coef, score = score,
         vc = diag(length(coef)) / n),
    class = "coverage_model"
  )
}

make_hurdle <- function(count_dist, zero_dist, separate = TRUE, weights = NULL,
                        offset = list(count = NULL, zero = NULL)) {
  y <- c(0, 1, 2)
  structure(
    list(
      model = data.frame(y = y),
      y = y,
      X = matrix(1, length(y), 1),
      Z = matrix(1, length(y), 1),
      offset = offset,
      dist = list(count = count_dist, zero = zero_dist),
      linkinv = plogis,
      coefficients = list(count = c(0.2), zero = c(-0.4)),
      theta = c(count = 1.3, zero = 0.8),
      separate = separate,
      weights = weights
    ),
    class = "hurdle"
  )
}

make_zeroinfl <- function(dist, weights = NULL,
                          offset = list(count = NULL, zero = NULL)) {
  y <- c(0, 1, 2)
  structure(
    list(
      model = data.frame(y = y),
      y = y,
      X = matrix(1, length(y), 1),
      Z = matrix(1, length(y), 1),
      offset = offset,
      dist = dist,
      linkinv = plogis,
      coefficients = list(count = c(0.2), zero = c(-0.4)),
      theta = 1.3,
      weights = weights
    ),
    class = "zeroinfl"
  )
}

test_that("glm family branches are covered", {
  grouped <- data.frame(success = c(1, 2, 3), failure = c(3, 2, 1), x = c(0, 1, 2))
  grouped_fit <- glm(cbind(success, failure) ~ x, data = grouped,
                     family = binomial, y = TRUE)
  grouped_fit$y <- as.matrix(grouped[, c("success", "failure")])
  expect_length(llcont(grouped_fit), nrow(grouped))

  bin_fit <- glm(am ~ hp, data = mtcars, family = binomial, y = TRUE)
  expect_equal(sum(llcont(bin_fit)), as.numeric(logLik(bin_fit)))

  expect_true(is.na(llcont(glm(am ~ hp, data = mtcars, family = quasibinomial, y = TRUE))))

  pois_data <- data.frame(y = c(1, 3, 2, 4), x = c(0, 1, 2, 3))
  pois_fit <- glm(y ~ x, data = pois_data, family = poisson, y = TRUE)
  expect_equal(sum(llcont(pois_fit)), as.numeric(logLik(pois_fit)))
  expect_true(is.na(llcont(glm(y ~ x, data = pois_data, family = quasipoisson, y = TRUE))))

  gauss_fit <- glm(mpg ~ hp, data = mtcars, family = gaussian, y = TRUE)
  expect_equal(sum(llcont(gauss_fit)), as.numeric(logLik(gauss_fit)))

  inv_data <- data.frame(y = c(1.2, 1.8, 2.4, 3.0), x = c(1, 2, 3, 4))
  inv_fit <- glm(y ~ x - 1, data = inv_data,
                 family = inverse.gaussian(link = "identity"), y = TRUE)
  expect_length(llcont(inv_fit), nrow(inv_data))

  gamma_fit <- glm(y ~ x, data = inv_data, family = Gamma, y = TRUE)
  expect_equal(sum(llcont(gamma_fit)), as.numeric(logLik(gamma_fit)))
})

test_that("remaining llcont S3 methods cover local branches", {
  nb <- structure(
    list(y = c(0, 1, 3), theta = 1.5, fitted.values = c(0.5, 1.0, 2.0),
         prior.weights = c(1, 2, 1)),
    class = "negbin"
  )
  expect_length(llcont(nb), 3)

  clm_weighted <- structure(
    list(mpreds = c(0.25, 0.75),
         mf = data.frame("(weights)" = c(2, 3), check.names = FALSE),
         ll = structure(-1, class = "logLik")),
    class = "clm"
  )
  expect_equal(llcont(clm_weighted), c(2, 3) * log(c(0.25, 0.75)))

  clm_infinite <- structure(
    list(mpreds = c(0.25, 0.75), mf = data.frame(y = 1:2),
         ll = structure(Inf, class = "logLik")),
    class = "clm"
  )
  expect_equal(llcont(clm_infinite), Inf)

  expect_error(llcont(structure(list(model = NULL), class = "hurdle")), "model=TRUE")
  expect_length(llcont(make_hurdle("poisson", "poisson")), 3)
  expect_length(llcont(make_hurdle("negbin", "negbin")), 3)
  expect_length(llcont(make_hurdle("geometric", "geometric", separate = FALSE)), 3)
  expect_length(llcont(make_hurdle("poisson", "binomial", weights = c(1, 2, 3),
                                   offset = list(count = c(0, 0, 0), zero = c(0, 0, 0)))), 3)

  expect_error(llcont(structure(list(model = NULL), class = "zeroinfl")), "model=TRUE")
  expect_length(llcont(make_zeroinfl("poisson")), 3)
  expect_length(llcont(make_zeroinfl("geometric")), 3)
  expect_length(llcont(make_zeroinfl("negbin", weights = c(1, 2, 3),
                                     offset = list(count = c(0, 0, 0), zero = c(0, 0, 0)))), 3)

  expect_equal(llcont(structure(list(prob = c(0.2, 0.8)), class = "mlogit")),
               log(c(0.2, 0.8)))
  expect_equal(llcont(structure(list(ll = c(-1, -2)), class = "vglm")), c(-1, -2))
})

test_that("lm and robust-lm edge branches are covered", {
  multi <- lm(cbind(mpg, disp) ~ hp, data = mtcars)
  expect_error(llcont(multi), "multiple responses")

  weighted_lm <- lm(mpg ~ hp, data = mtcars[1:6, ], weights = c(1, 0, 1, 1, 0, 1))
  expect_length(llcont(weighted_lm), 4)

  rlm_unweighted <- structure(
    list(residuals = c(1, -1, 0.5), rank = 1, weights = NULL),
    class = "rlm"
  )
  expect_length(llcont(rlm_unweighted), 3)

  rlm_weighted <- structure(
    list(residuals = c(1, -1, 0.5), rank = 1, weights = c(1, 0, 2)),
    class = "rlm"
  )
  expect_length(llcont(rlm_weighted), 2)
})

test_that("icci and print methods are covered", {
  obj1 <- make_coverage_model(c(-1.0, -1.2, -1.4), coef = c(a = 1), call = quote(obj1()))
  obj2 <- make_coverage_model(c(-1.1, -1.1, -1.5), coef = c(a = 1, b = 2),
                              score = matrix(c(1, 0, 0, 1, 1, 1), ncol = 2),
                              call = quote(obj2()))
  res <- icci(obj1, obj2, ll1 = function(x) x$ll, ll2 = function(x) x$ll)
  expect_s3_class(res, "icci")
  expect_output(print(res), "Confidence Interval of BIC difference")
})

test_that("vuongtest nonnested, nested, and print branches are covered", {
  obj1 <- make_coverage_model(c(-1.3, -1.1, -1.6), call = quote(short_call()))
  obj2 <- make_coverage_model(c(-1.0, -1.4, -1.2), call = quote(very_long_call_name(1, 2, 3, 4, 5)))

  vt <- suppressWarnings(
    vuongtest(obj1, obj2, ll1 = function(x) x$ll, ll2 = function(x) x$ll,
              score1 = function(x) x$score, score2 = function(x) x$score,
              vc1 = function(x) x$vc, vc2 = function(x) x$vc)
  )
  expect_s3_class(vt, "vuongtest")
  expect_output(print(vt), "Non-nested likelihood ratio test")

  better <- make_coverage_model(c(-0.5, -0.6, -0.8), call = quote(better_model()))
  nested <- suppressWarnings(
    vuongtest(obj1, better, nested = TRUE,
              ll1 = function(x) x$ll, ll2 = function(x) x$ll,
              score1 = function(x) x$score, score2 = function(x) x$score,
              vc1 = function(x) x$vc, vc2 = function(x) x$vc)
  )
  expect_s3_class(nested, "vuongtest")
  expect_output(print(nested), "Robust likelihood ratio test")
})

test_that("internal matrix helpers cover supported branches", {
  lm_fit <- lm(mpg ~ hp, data = mtcars[1:8, ])
  lm_ab <- nonnest2:::calcAB(lm_fit, nobs(lm_fit), NULL, vcov)
  expect_named(lm_ab, c("A", "B", "sc"))

  glm_fit <- glm(am ~ hp, data = mtcars, family = binomial, y = TRUE)
  glm_ab <- nonnest2:::calcAB(glm_fit, length(glm_fit$y), NULL, vcov)
  expect_named(glm_ab, c("A", "B", "sc"))

  obj <- make_coverage_model(c(-1, -2, -1.5))
  custom_ab <- nonnest2:::calcAB(obj, length(obj$ll), function(x) x$score, function(x) x$vc)
  expect_named(custom_ab, c("A", "B", "sc"))

  estfun_ab <- nonnest2:::calcAB(obj, length(obj$ll), NULL, function(x) x$vc)
  expect_named(estfun_ab, c("A", "B", "sc"))

  bad_vc <- function(x) matrix(NA_real_, 1, 1)
  expect_error(nonnest2:::calcAB(obj, 3, function(x) matrix(1, 3, 1), bad_vc),
               "re-estimate")
  expect_equal(nonnest2:::calcBcross(matrix(1:4, 2), matrix(5:8, 2), 2),
               crossprod(matrix(1:4, 2), matrix(5:8, 2)) / 2)
})

test_that("lavaan-specific likelihood and matrix branches are covered", {
  skip_if_not_installed("lavaan")
  suppressPackageStartupMessages(library(lavaan))

    HS.model <- "visual  =~ x1 + x2 + x3
                 textual =~ x4 + x5 + x6
                 speed   =~ x7 + x8 + x9"

    fit_mlr <- lavaan::cfa(HS.model, data = lavaan::HolzingerSwineford1939,
                           estimator = "MLR")
    expect_error(llcont(fit_mlr), "fit via ML")

    data_missing <- lavaan::HolzingerSwineford1939[, paste0("x", 1:9)]
    data_missing[1, "x1"] <- NA
    data_missing[2, "x2"] <- NA
    fit_pairwise <- lavaan::cfa(HS.model, data = data_missing, missing = "pairwise")
    expect_error(llcont(fit_pairwise), "pairwise/listwise")

    model_with_x <- "f =~ x1 + x2 + x3
                     f ~ x4 + x5"
    data_with_x <- lavaan::HolzingerSwineford1939[, c("x1", "x2", "x3", "x4", "x5")]
    data_with_x[1, "x4"] <- NA
    fit_ml_x <- lavaan::sem(model_with_x, data = data_with_x, missing = "ml.x",
                            fixed.x = TRUE, meanstructure = TRUE)
    expect_error(llcont(fit_ml_x), "missing='ml.x'")

    fit_fixed_x <- lavaan::sem(model_with_x, data = data_with_x[-1, ],
                               fixed.x = TRUE, meanstructure = TRUE)
    expect_equal(sum(llcont(fit_fixed_x)),
                 as.numeric(lavaan::fitMeasures(fit_fixed_x, "logl")))

    model_one_x <- "f =~ x1 + x2 + x3
                    f ~ x4"
    data_one_x <- lavaan::HolzingerSwineford1939[, c("x1", "x2", "x3", "x4")]
    fit_one_x <- lavaan::sem(model_one_x, data = data_one_x,
                             fixed.x = TRUE, meanstructure = TRUE)
    fit_one_x@SampleStats@mean.x <- list(NULL)
    fit_one_x@SampleStats@cov.x <- list(NULL)
    expect_equal(sum(llcont(fit_one_x)),
                 as.numeric(lavaan::fitMeasures(fit_one_x, "logl")))

    data_one_x[1, c("x2", "x3")] <- NA
    fit_missing_one_x <- lavaan::sem(model_one_x, data = data_one_x,
                                     fixed.x = TRUE, meanstructure = TRUE,
                                     missing = "ml")
    expect_equal(sum(llcont(fit_missing_one_x)),
                 as.numeric(lavaan::fitMeasures(fit_missing_one_x, "logl")))

    set.seed(100)
    factor_score <- rnorm(200)
    one_observed <- data.frame(
      y1 = 0.8 * factor_score + rnorm(200, sd = 0.4),
      y2 = 0.7 * factor_score + rnorm(200, sd = 0.4),
      y3 = 0.9 * factor_score + rnorm(200, sd = 0.4)
    )
    one_observed[1, c("y2", "y3")] <- NA
    fit_one_observed <- lavaan::cfa("f =~ y1 + y2 + y3", data = one_observed,
                                    missing = "ml", meanstructure = TRUE)
    expect_equal(sum(llcont(fit_one_observed)),
                 as.numeric(lavaan::fitMeasures(fit_one_observed, "logl")))

    fit1 <- lavaan::cfa(HS.model, data = lavaan::HolzingerSwineford1939)
    fit2 <- lavaan::cfa(HS.model, data = lavaan::HolzingerSwineford1939,
                        group = "school")
    fit3 <- lavaan::cfa(HS.model, data = lavaan::HolzingerSwineford1939,
                        group = "school", group.equal = c("loadings"))
    expect_s3_class(vuongtest(fit1, fit2), "vuongtest")
    expect_s3_class(vuongtest(fit2, fit3, nested = TRUE), "vuongtest")

    weighted_data <- lavaan::HolzingerSwineford1939
    weighted_data$wt <- 1
    fit_weighted <- lavaan::cfa(HS.model, data = weighted_data,
                                sampling.weights = "wt")
    expect_error(nonnest2:::check.obj(fit_weighted, list(call = quote(other()))),
                 "sampling weights")
    expect_error(nonnest2:::check.obj(list(call = quote(other())), fit_weighted),
                 "sampling weights")
})

test_that("mirt single-group and survey-weight branches are covered", {
  skip_if_not_installed("mirt")
  suppressPackageStartupMessages(library(mirt))

    data("LSAT7", package = "mirt")
    item_data <- mirt::expand.table(LSAT7)

    single_group <- mirt::mirt(item_data, 1, SE = TRUE, SE.type = "Oakes",
                               verbose = FALSE)
    expect_length(llcont(single_group), nrow(item_data))

    weighted_group <- mirt::mirt(item_data, 1, survey.weights = rep(1, nrow(item_data)),
                                 SE = TRUE, SE.type = "Oakes", verbose = FALSE)
    expect_named(nonnest2:::calcAB(weighted_group, nrow(item_data), NULL, vcov),
                 c("A", "B", "sc"))

    non_oakes <- single_group
    non_oakes@Options$SE.type <- "not-Oakes"
    expect_warning(nonnest2:::check.obj(non_oakes, list(call = quote(other()))),
                   "Oakes")
    expect_warning(nonnest2:::check.obj(list(call = quote(other())), non_oakes),
                   "Oakes")
})

test_that("check.obj S4 and error branches are covered", {
  if (!methods::isClass("CoverageCallS4")) {
    methods::setClass("CoverageCallS4", slots = c(call = "ANY"))
  }
  if (!methods::isClass("CoverageNoCallS4")) {
    methods::setClass("CoverageNoCallS4", slots = c(value = "numeric"))
  }
  if (!methods::isClass("MxModel")) {
    methods::setClass("MxModel", slots = c(name = "character"))
  }

  plain <- list(call = quote(plain()))
  s4_with_call <- methods::new("CoverageCallS4", call = quote(s4_call()))
  s4_without_call <- methods::new("CoverageNoCallS4", value = 1)
  mx <- methods::new("MxModel", name = "mx-name")

  expect_equal(nonnest2:::check.obj(s4_with_call, plain)$callA, quote(s4_call()))
  expect_equal(nonnest2:::check.obj(plain, s4_with_call)$callB, quote(s4_call()))
  expect_equal(nonnest2:::check.obj(mx, plain)$callA, "mx-name")
  expect_equal(nonnest2:::check.obj(plain, mx)$callB, "mx-name")
  expect_error(nonnest2:::check.obj(s4_without_call, plain), "object1")
  expect_error(nonnest2:::check.obj(plain, s4_without_call), "object2")
})
