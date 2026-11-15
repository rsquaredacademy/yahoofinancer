test_that("live opt-in bypasses both offline setup bindings", {
  old <- Sys.getenv("YF_LIVE_TESTS", unset = NA_character_)
  on.exit(if (is.na(old)) Sys.unsetenv("YF_LIVE_TESTS") else Sys.setenv(YF_LIVE_TESTS = old))
  for (live in c("", "true")) {
    Sys.setenv(YF_LIVE_TESTS = live)
    bindings <- list()
    testthat::with_mocked_bindings(
      sys.source(test_path("setup-hermetic.R"), envir = new.env()),
      local_mocked_bindings = function(...) bindings[[length(bindings) + 1L]] <<- list(...),
      .package = "testthat"
    )
    expect_length(bindings, if (live == "true") 0L else 2L)
    if (live != "true") {
      expect_identical(bindings[[1]]$.package, "httr2")
      expect_error(bindings[[1]]$req_perform1(), "Unmocked network request blocked")
      expect_true(bindings[[2]]$has_internet())
    }
  }
})
