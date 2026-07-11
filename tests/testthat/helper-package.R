suppressWarnings(suppressPackageStartupMessages(library(nonnest2)))

load_test_package <- function(package) {
  testthat::skip_if_not_installed(package)
  suppressWarnings(
    suppressPackageStartupMessages(library(package, character.only = TRUE))
  )
}

with_test_packages <- function(packages, code) {
  for (package in packages) {
    load_test_package(package)
  }
  force(code)
}
