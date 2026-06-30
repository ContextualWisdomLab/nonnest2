if (requireNamespace("testthat", quietly = TRUE)) {
  library(testthat)
  library(nonnest2)

  test_check("nonnest2")
} else {
  message("testthat package not available, skipping tests.")
}
