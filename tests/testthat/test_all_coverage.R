context("100% coverage")

test_that("icci edge cases", {
  ctl <- c(4.17,5.58,5.18,6.11,4.50,4.61,5.17,4.53,5.33,5.14)
  trt <- c(4.81,4.17,4.41,3.59,5.87,3.83,6.03,4.89,4.32,4.69)
  group <- gl(2, 10, 20, labels = c("Ctl","Trt"))
  weight <- c(ctl, trt)
  lm1 <- lm(weight ~ 1)
  lm2 <- lm(weight ~ group)

  res <- icci(lm1, lm2)
  expect_s3_class(res, "icci")
  expect_output(print(res), "Model 1")
})

test_that("vuongtest edge cases", {
  ctl <- c(4.17,5.58,5.18,6.11,4.50,4.61,5.17,4.53,5.33,5.14)
  trt <- c(4.81,4.17,4.41,3.59,5.87,3.83,6.03,4.89,4.32,4.69)
  group <- gl(2, 10, 20, labels = c("Ctl","Trt"))
  weight <- c(ctl, trt)
  lm1 <- lm(weight ~ 1)
  lm2 <- lm(weight ~ group)

  res <- vuongtest(lm1, lm2)
  expect_s3_class(res, "vuongtest")
  expect_output(print(res), "Model 1")

  res2 <- vuongtest(lm1, lm2, nested=TRUE)
  expect_s3_class(res2, "vuongtest")

  # Indistinguishable models
  lm3 <- lm(weight ~ group)
  res3 <- vuongtest(lm2, lm3)
  expect_s3_class(res3, "vuongtest")
})
