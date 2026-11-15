# Opt-in only: set YF_LIVE_TESTS=true to contact Yahoo Finance. By default this
# file is skipped, so the suite never makes live requests.
if (!identical(Sys.getenv("YF_LIVE_TESTS"), "true")) {
  testthat::skip("Live tests are opt-in: set YF_LIVE_TESTS=true to run them.")
}
testthat::skip_on_cran()
testthat::skip_if_offline()

test_that("Live Yahoo Finance endpoints respond and return valid schemas", {
  symbols <- c("AAPL", "GOOG", "^NSEI")

  for (sym in symbols) {
    obj <- if (startsWith(sym, "^")) {
      Index$new(sym)
    } else {
      Ticker$new(sym)
    }

    # Historical price test
    hist <- obj$get_history(period = "5d", interval = "1d")
    expect_s3_class(hist, "tbl_df")
    expect_gt(nrow(hist), 0)
    expect_equal(names(hist), c("symbol", "date", "open", "high", "low", "close", "adj_close", "volume"))

    # Statements test for equity tickers
    if (!startsWith(sym, "^")) {
      inc <- obj$get_income_statement(frequency = "annual")
      expect_s3_class(inc, "tbl_df")
      expect_gt(nrow(inc), 0)
      expect_true("total_revenue" %in% names(inc))
    }
  }
})
