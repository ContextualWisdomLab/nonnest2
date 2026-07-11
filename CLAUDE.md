# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

nonnest2 is a CRAN R package (GPL-2 | GPL-3) implementing Vuong's (1989) theory for comparing non-nested models: a test of model distinguishability, a (robust) likelihood-ratio test of model fit usable for both nested and non-nested models, and confidence intervals for AIC/BIC differences. It works automatically for many model classes (lavaan, mirt, OpenMx, glm, pscl's hurdle/zeroinfl, ...) and is extensible to unseen classes. This repo (ContextualWisdomLab/nonnest2) is a fork of the upstream qpsy/nonnest2 listed in DESCRIPTION.

## Commands

Run from the repo root. R with the Imports (CompQuadForm, mvtnorm, lavaan >= 0.6-6, sandwich) is required; most tests additionally need Suggests packages (mirt, pscl, ordinal, mlogit, MASS, ...) and skip when they are missing.

```bash
# Full test suite (loads the package from source via pkgload::load_all — no install needed)
Rscript -e 'testthat::test_dir("tests/testthat")'

# Single test file (helpers in tests/testthat/ are auto-sourced)
Rscript -e 'testthat::test_file("tests/testthat/test_llcont.R")'

# Regenerate man/*.Rd and NAMESPACE from roxygen comments (RoxygenNote 7.3.3)
Rscript -e 'devtools::document()'   # or roxygen2::roxygenise()

# CRAN-style build & check — the quality gate (no CI workflows, Makefile, or lint config exist)
R CMD build .                       # add --no-build-vignettes if LaTeX is unavailable
R CMD check --as-cran nonnest2_*.tar.gz

# Build the vignette alone (PDF output; needs LaTeX)
Rscript -e 'devtools::build_vignettes()'
```

## Architecture

Three source files in `R/`, three exports (`vuongtest`, `icci`, `llcont`):

- `R/llcont.R` — `llcont()` S3 generic returning casewise log-likelihood contributions (invariant: they sum to `logLik(x)`), with methods for glm, negbin, clm, hurdle, zeroinfl, mlogit, lm, nls, polr, rlm, vglm, lavaan, mirt (SingleGroupClass / MultipleGroupClass / DiscreteClass), and OpenMx (MxModel). This is the extension point: supporting a new model class means adding a `llcont.<class>` method (scores come from `sandwich::estfun`).
- `R/vuongtest.R` — `vuongtest()` plus the numerical core: `calcAB()` (Vuong Eq 2.1/2.2 from vcov and scores), `calcBcross()` (Eq 2.7), `calcLambda()` (eigenvalues of W, Eq 3.6, fed to `CompQuadForm::imhof`), `check.obj()` (shared validation: extracts call/class, rejects lavaan sampling weights, warns unless mirt `SE.type="Oakes"`), `print.vuongtest`, and `.onAttach`.
- `R/icci.R` — `icci()` AIC/BIC confidence intervals; reuses `check.obj()` and `llcont()`; `print.icci`.

Class-specific behavior dispatches on `class(object)[1]` inside `calcAB()`/`check.obj()`: lavaan uses `estfun(..., remove.duplicated=TRUE)` and de-duplicates vcov columns to handle equality constraints; parameter counts come from `mirt::extract.mirt(obj, "nest")` for mirt objects and `attr(logLik(obj), "df")` for lavaan. Callers can bypass dispatch entirely by passing custom `ll1/ll2`, `score1/score2`, `vc1/vc2` functions to `vuongtest()` (how lme4 models are supported via merDeriv).

## Tests

- `tests/testthat/helper-package.R` loads the package from source with `pkgload::load_all()` (falls back to an installed copy) and defines `load_test_package()` / `with_test_packages()`, which `skip_if_not_installed()`. Wrap any test that needs a Suggests package in these helpers rather than calling `library()` directly.
- `test_llcont.R` verifies `sum(llcont(fit)) == logLik(fit)` across model classes (including lavaan with equality constraints and missing data); `test_discreteclass.R` covers the mirt DiscreteClass paths.

## Conventions

- `man/` and `NAMESPACE` are roxygen2-generated ("do not edit by hand") — edit the roxygen blocks in `R/` and re-document. Record user-visible changes in `NEWS` (plain text, newest first); bump `Version`/`Date` in DESCRIPTION for releases.
- The vignette (`vignettes/nonnest2.Rmd`, knitr → PDF via `nonnest2-preamble.tex`) is the canonical usage doc for the two-step Vuong procedure (distinguishability test, then LRT).
- Wrap fallible internal calls in `tryCatch()` or `try(..., silent = TRUE)`; a prior security fix (documented in `.jules/sentinel.md`) removed error-message leakage from a bare `try()`.
