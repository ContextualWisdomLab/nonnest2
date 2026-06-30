if (requireNamespace("testthat", quietly = TRUE)) {
  library(testthat)
  library(nonnest2)
  if (requireNamespace("rstudioapi", quietly = TRUE)) {
    test_check("nonnest2")
  } else {
    message("rstudioapi package not available, skipping tests.")
  }
} else {
  message("testthat package not available, skipping tests.")
}
