# M1/M2: full failures return typed zero-row tibbles with the documented
# columns; absent metadata is a failed symbol, not a row of untyped NAs.

price_cols <- c("symbol", "date", "open", "high", "low", "close", "adj_close", "volume")
stat_cols <- c(
  "symbol", "regular_market_price", "fifty_two_week_high", "fifty_two_week_low",
  "regular_market_volume", "previous_close", "currency"
)
invalid <- function(symbol, ...) setNames(rep(FALSE, length(symbol)), symbol)

test_that("full-failure results keep the documented columns and types", {
  testthat::with_mocked_bindings(
    {
      p <- suppressWarnings(yf_download_prices("BAD"))
      expect_equal(names(p), price_cols)
      expect_equal(nrow(p), 0)
      expect_s3_class(p$date, "POSIXct")
      expect_type(p$close, "double")

      i <- suppressWarnings(yf_get_index_quotes("BAD"))
      expect_equal(names(i), price_cols)
      expect_equal(nrow(i), 0)

      s <- suppressWarnings(yf_get_market_stats("BAD"))
      expect_equal(names(s), stat_cols)
      expect_equal(nrow(s), 0)
      expect_type(s$regular_market_price, "double")
      expect_type(s$currency, "character")

      f <- suppressWarnings(yf_get_financials("BAD"))
      expect_true(all(c("symbol", "date", "period_type") %in% names(f)))
      expect_equal(nrow(f), 0)

      h <- suppressWarnings(Tickers$new("BAD", validate = FALSE)$get_history())
      expect_equal(names(h), price_cols)
      expect_equal(nrow(h), 0)

      # downstream dplyr verbs work on a failed call
      expect_no_error(dplyr::select(p, symbol, date))
    },
    validate = invalid,
    api_request = function(...) NULL,
    .package = "yahoofinancer"
  )
})

test_that("market stats with failing metadata warns once per symbol and makes one request", {
  count <- 0L
  stub <- function(url, ...) {
    count <<- count + 1L
    if (grepl("validate", url)) {
      return(list(symbolsValidation = list(result = list(list(AAPL = TRUE)))))
    }
    NULL
  }
  with_api(stub, {
    expect_warning(res <- yf_get_market_stats("AAPL"), "Failed to fetch data for ticker: AAPL")
  })
  expect_equal(names(res), stat_cols)
  expect_equal(nrow(res), 0)
  # one validation request plus one metadata request
  expect_equal(count, 2L)
})

test_that("market stats rows are typed even when a field is missing", {
  stub <- function(url, ...) {
    if (grepl("validate", url)) {
      return(list(symbolsValidation = list(result = list(list(AAPL = TRUE)))))
    }
    list(chart = list(result = list(list(meta = list(
      currency = "USD", regularMarketPrice = 100, previousClose = 99
    )))))
  }
  with_api(stub, {
    res <- yf_get_market_stats("AAPL")
  })
  expect_equal(nrow(res), 1)
  expect_equal(res$regular_market_price, 100)
  expect_equal(res$previous_close, 99)
  expect_equal(res$currency, "USD")
  expect_true(is.na(res$fifty_two_week_high))
  expect_type(res$fifty_two_week_high, "double")
  expect_type(res$regular_market_volume, "double")
})
