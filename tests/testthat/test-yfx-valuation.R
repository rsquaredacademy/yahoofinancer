# H1: valuation measures are joined by observation date, never by position.

valuation_item <- function(name, dates, values) {
  type <- paste0("quarterly", name)
  item <- list(
    meta = list(type = list(type)),
    timestamp = as.list(as.numeric(as.POSIXct(dates, tz = "UTC")))
  )
  item[[type]] <- Map(function(date, value) {
    list(asOfDate = date, periodType = "3M", reportedValue = list(raw = value))
  }, dates, values)
  item
}

valuation_payload <- function(market_cap_item) {
  dates <- c("2023-03-31", "2023-06-30")
  metrics <- c(
    "EnterpriseValue", "EnterprisesValueEBITDARatio",
    "EnterprisesValueRevenueRatio", "ForwardPeRatio", "MarketCap",
    "PbRatio", "PeRatio", "PegRatio", "PsRatio"
  )
  items <- lapply(metrics, function(m) {
    if (m == "MarketCap") market_cap_item else valuation_item(m, dates, c(10, 20))
  })
  items <- Filter(Negate(is.null), items)
  list(timeseries = list(result = items))
}

dates <- c("2023-03-31", "2023-06-30")

test_that("valuation measures align by asOfDate when a metric is reordered", {
  payload <- valuation_payload(valuation_item("MarketCap", rev(dates), c(200, 100)))
  with_api(payload, {
    res <- Ticker$new("TEST", validate = FALSE)$valuation_measures
  })
  expect_equal(res$date, as.Date(dates))
  expect_equal(res$market_cap, c(100, 200))
  expect_equal(res$enterprise_value, c(10, 20))
})

test_that("valuation measures give NA for a metric missing a quarter, not a recycled value", {
  payload <- valuation_payload(valuation_item("MarketCap", dates[2], 200))
  with_api(payload, {
    res <- Ticker$new("TEST", validate = FALSE)$valuation_measures
  })
  expect_equal(res$market_cap, c(NA, 200))
})

test_that("valuation measures keep a typed NA column for an absent metric", {
  payload <- valuation_payload(NULL)
  with_api(payload, {
    res <- Ticker$new("TEST", validate = FALSE)$valuation_measures
  })
  expect_equal(nrow(res), 2)
  expect_type(res$market_cap, "double")
  expect_true(all(is.na(res$market_cap)))
  expect_equal(res$pe_ratio, c(10, 20))
})

test_that("valuation measures take the union of dates across metrics", {
  payload <- valuation_payload(valuation_item("MarketCap", c("2023-09-30"), 300))
  with_api(payload, {
    res <- Ticker$new("TEST", validate = FALSE)$valuation_measures
  })
  expect_equal(res$date, as.Date(c(dates, "2023-09-30")))
  expect_equal(res$market_cap, c(NA, NA, 300))
  expect_equal(res$enterprise_value, c(10, 20, NA))
})
