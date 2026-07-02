if (!requireNamespace("testthat", quietly = TRUE)) {
  install.packages("testthat", repos = "http://cran.us.r-project.org")
}
library(testthat)
library(nonnest2)

test_check("nonnest2")
