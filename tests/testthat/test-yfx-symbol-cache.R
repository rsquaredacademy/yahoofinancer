# H4: cached metadata is keyed by symbol, so assigning the public field is safe.

price_stub <- function() {
  prices <- list(AAPL = 100, MSFT = 200)
  calls <- 0L
  list(
    fn = function(url, ...) {
      calls <<- calls + 1L
      symbol <- sub(".*/", "", url)
      list(chart = list(result = list(list(meta = list(
        currency = "USD", regularMarketPrice = prices[[symbol]]
      )))))
    },
    calls = function() calls
  )
}

test_that("assigning the public symbol field returns the new ticker's price", {
  st <- price_stub()
  with_api(st$fn, {
    t <- Ticker$new("AAPL", validate = FALSE)
    expect_equal(t$regular_market_price, 100)
    t$symbol <- "MSFT"
    expect_equal(t$symbol, "MSFT")
    expect_equal(t$regular_market_price, 200)
  })
})

test_that("set_symbol() still refreshes, and repeated reads use one request", {
  st <- price_stub()
  with_api(st$fn, {
    t <- Ticker$new("AAPL", validate = FALSE)
    t$regular_market_price
    t$currency
    expect_equal(st$calls(), 1L)
    t$set_symbol("MSFT", validate = FALSE)
    expect_equal(t$regular_market_price, 200)
    expect_equal(st$calls(), 2L)
  })
})
