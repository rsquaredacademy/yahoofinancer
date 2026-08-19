library(testthat)
library(yahoofinancer)

test_that('parse_chart_data returns empty tibble for NULL input', {
  res <- yahoofinancer:::parse_chart_data(NULL, 'AAPL')
  expect_s3_class(res, 'tbl_df')
  expect_equal(nrow(res), 0)
  expect_equal(names(res), c('symbol', 'date', 'open', 'high', 'low', 'close', 'adj_close', 'volume'))
})

test_that('parse_chart_data returns empty tibble when timestamp is missing', {
  res <- yahoofinancer:::parse_chart_data(list(indicators = list()), 'AAPL')
  expect_equal(nrow(res), 0)
})

test_that('parse_chart_data returns empty tibble when timestamp is empty', {
  res <- yahoofinancer:::parse_chart_data(list(timestamp = list()), 'AAPL')
  expect_equal(nrow(res), 0)
})

test_that('parse_chart_data uses adj_close when present and matching', {
  data <- list(
    timestamp = list(1625059200, 1625145600),
    indicators = list(
      quote = list(list(open = list(100, 101), high = list(105, 106),
                        low = list(99, 100), close = list(104, 105),
                        volume = list(1000, 1100))),
      adjclose = list(list(adjclose = list(103.5, 104.5)))
    )
  )
  res <- yahoofinancer:::parse_chart_data(data, 'TEST')
  expect_equal(res$adj_close, c(103.5, 104.5))
  expect_false(identical(res$adj_close, res$close))
})

test_that('parse_chart_data falls back to close when adj_close length mismatches', {
  data <- list(
    timestamp = list(1625059200, 1625145600),
    indicators = list(
      quote = list(list(open = list(100, 101), high = list(105, 106),
                        low = list(99, 100), close = list(104, 105),
                        volume = list(1000, 1100))),
      adjclose = list(list(adjclose = list(103.5)))
    )
  )
  res <- yahoofinancer:::parse_chart_data(data, 'TEST')
  expect_equal(res$adj_close, res$close)
})

test_that('parse_chart_data falls back to close when adj_close is NULL', {
  data <- list(
    timestamp = list(1625059200),
    indicators = list(
      quote = list(list(open = list(100), high = list(105),
                        low = list(99), close = list(104),
                        volume = list(1000)))
    )
  )
  res <- yahoofinancer:::parse_chart_data(data, 'TEST')
  expect_equal(res$adj_close, res$close)
})

test_that('parse_chart_data handles NULL values in adj_close list', {
  data <- list(
    timestamp = list(1625059200, 1625145600),
    indicators = list(
      quote = list(list(open = list(100, 101), high = list(105, 106),
                        low = list(99, 100), close = list(104, 105),
                        volume = list(1000, 1100))),
      adjclose = list(list(adjclose = list(103.5, NULL)))
    )
  )
  res <- yahoofinancer:::parse_chart_data(data, 'TEST')
  expect_equal(res$adj_close[1], 103.5)
  expect_true(is.na(res$adj_close[2]))
})
