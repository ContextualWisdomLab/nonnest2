# Reproducible benchmark harness
# Install the optional benchmark dependency with:
# install.packages("microbenchmark")
library(microbenchmark)

run_zeroPoisson_orig <- function(Z, parms, offsetz, weights, Y0, Y1) {
  mu <- as.vector(exp(Z %*% parms + offsetz))
  loglik0 <- -mu
  Y0 * weights * loglik0 + ifelse(Y1, weights * log(1 - exp(loglik0)), 0)
}

run_zeroPoisson_opt <- function(Z, parms, offsetz, weights, Y0, Y1) {
  mu <- as.vector(exp(Z %*% parms + offsetz))
  loglik0 <- -mu
  res_Y1 <- Y1 * 0
  cond <- Y1; cond[is.na(cond)] <- FALSE
  if (any(cond)) {
    w_c <- if (length(weights) == 1) rep_len(weights, sum(cond)) else weights[cond]
    res_Y1[cond] <- w_c * log(1 - exp(loglik0[cond]))
  }
  Y0 * weights * loglik0 + res_Y1
}

# Generate mostly zeros (so Y1 is mostly FALSE)
set.seed(20260811)
n <- 1000000
Z <- matrix(rnorm(n*2), n, 2)
parms <- c(0.5, -0.5)
offsetz <- rep(0, n)
Y <- rbinom(n, 1, 0.1)
Y0 <- Y <= 0
Y1 <- Y > 0
weights <- 1

bm <- microbenchmark(
  original = run_zeroPoisson_orig(Z, parms, offsetz, weights, Y0, Y1),
  optimized = run_zeroPoisson_opt(Z, parms, offsetz, weights, Y0, Y1),
  times = 100,
  control = list(warmup = 10)
)
print(bm)

med_orig <- median(bm$time[bm$expr == "original"])
med_opt <- median(bm$time[bm$expr == "optimized"])
improvement <- (med_orig - med_opt) / med_orig

cat(sprintf("Performance improvement: %.2f%%\n", improvement * 100))
cat("Timing is descriptive; compare thresholds only in a controlled environment.\n")
