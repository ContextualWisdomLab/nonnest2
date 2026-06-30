if (requireNamespace("testthat", quietly = TRUE)) {
  library(testthat)
  if (requireNamespace("rstudioapi", quietly = TRUE)) {
    library(nonnest2)
    test_check("nonnest2")
  } else {
    message("rstudioapi package not available, skipping tests.")
  }
} else {
  message("testthat package not available, skipping tests.")
}
