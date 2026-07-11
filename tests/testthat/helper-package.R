find_test_package_root <- function(path = getwd()) {
  path <- normalizePath(path, winslash = "/", mustWork = TRUE)
  repeat {
    if (file.exists(file.path(path, "DESCRIPTION"))) {
      return(path)
    }
    parent <- dirname(path)
    if (identical(parent, path)) {
      stop("Cannot find package root containing DESCRIPTION.", call. = FALSE)
    }
    path <- parent
  }
}

load_package_under_test <- function() {
  root <- find_test_package_root()
  if (requireNamespace("pkgload", quietly = TRUE)) {
    suppressWarnings(
      suppressPackageStartupMessages(
        pkgload::load_all(
          root,
          export_all = FALSE,
          helpers = FALSE,
          quiet = TRUE
        )
      )
    )
    return(invisible(TRUE))
  }
  testthat::skip_if_not_installed("nonnest2")
  suppressWarnings(suppressPackageStartupMessages(library(nonnest2)))
  invisible(TRUE)
}

load_package_under_test()

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
