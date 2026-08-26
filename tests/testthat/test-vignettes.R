# Smoke-tests for vignette code chunks
#
# These tests parse (but do not evaluate) the R code extracted from each
# vignette, catching syntax errors and references to functions that have
# been renamed or removed.  They run offline and add no network overhead.

# Helper: locate a vignette .Rmd file whether running under R CMD check
# (installed package) or interactively / via devtools::test() (source tree).
find_vignette_rmd <- function(name) {
  # 1. Source tree: check for .Rmd.orig first (for pre-computed vignettes like cookbook)
  root <- testthat::test_path("..", "..")
  orig <- file.path(root, "vignettes", paste0(name, ".Rmd.orig"))
  if (file.exists(orig)) return(orig)

  # 2. Installed location (R CMD check / R CMD build)
  installed <- system.file("doc", paste0(name, ".Rmd"), package = "yahoofinancer")
  if (nzchar(installed)) return(installed)

  # 3. Source tree standard .Rmd
  src <- file.path(root, "vignettes", paste0(name, ".Rmd"))
  if (file.exists(src)) return(src)

  NA_character_
}

test_that("comparing-portfolios vignette code parses cleanly", {
  skip_if_not_installed("knitr")
  rmd <- find_vignette_rmd("comparing-portfolios")
  skip_if(is.na(rmd), "Vignette source not found")

  tmp <- tempfile(fileext = ".R")
  on.exit(unlink(tmp), add = TRUE)

  knitr::purl(rmd, output = tmp, documentation = 0L, quiet = TRUE)
  expect_no_error(parse(file = tmp))
})

test_that("cookbook vignette code parses cleanly", {
  skip_if_not_installed("knitr")
  rmd <- find_vignette_rmd("cookbook")
  skip_if(is.na(rmd), "Vignette source not found")

  tmp <- tempfile(fileext = ".R")
  on.exit(unlink(tmp), add = TRUE)

  knitr::purl(rmd, output = tmp, documentation = 0L, quiet = TRUE)
  expect_no_error(parse(file = tmp))
})

test_that("first-stock-analysis vignette code parses cleanly", {
  skip_if_not_installed("knitr")
  rmd <- find_vignette_rmd("first-stock-analysis")
  skip_if(is.na(rmd), "Vignette source not found")

  tmp <- tempfile(fileext = ".R")
  on.exit(unlink(tmp), add = TRUE)

  knitr::purl(rmd, output = tmp, documentation = 0L, quiet = TRUE)
  expect_no_error(parse(file = tmp))
})

test_that("currency-conversion vignette code parses cleanly", {
  skip_if_not_installed("knitr")
  rmd <- find_vignette_rmd("currency-conversion")
  skip_if(is.na(rmd), "Vignette source not found")

  tmp <- tempfile(fileext = ".R")
  on.exit(unlink(tmp), add = TRUE)

  knitr::purl(rmd, output = tmp, documentation = 0L, quiet = TRUE)
  expect_no_error(parse(file = tmp))
})

test_that("shiny-dashboard vignette code parses cleanly", {
  skip_if_not_installed("knitr")
  rmd <- find_vignette_rmd("shiny-dashboard")
  skip_if(is.na(rmd), "Vignette source not found")

  tmp <- tempfile(fileext = ".R")
  on.exit(unlink(tmp), add = TRUE)

  knitr::purl(rmd, output = tmp, documentation = 0L, quiet = TRUE)
  expect_no_error(parse(file = tmp))
})
