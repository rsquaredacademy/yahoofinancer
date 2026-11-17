# H3: currency_converter() uses the guarded chart parser; adjusted closes are
# never recycled, missing quote fields are NA, empty charts give an empty tibble.

fx_payload <- function(quote, adjclose = NULL, ts = list(1672531200, 1672617600)) {
  ind <- list(quote = list(quote))
  if (!is.null(adjclose)) ind$adjclose <- list(list(adjclose = adjclose))
  list(chart = list(result = list(list(timestamp = ts, indicators = ind))))
}

test_that("a truncated adjusted-close series warns and falls back to close, not recycling", {
  q <- list(open = list(1, 2), high = list(1, 2), low = list(1, 2),
            close = list(1, 2), volume = list(0, 0))
  with_api(fx_payload(q, adjclose = list(0.9)), {
    expect_warning(
      res <- currency_converter("EUR", "USD", period = "5d"),
      "Adjusted close length"
    )
  })
  expect_equal(res$close, c(1, 2))
  expect_equal(res$adj_close, c(1, 2))
})

test_that("a complete adjusted-close series is returned in order", {
  q <- list(open = list(1, 2), high = list(1, 2), low = list(1, 2),
            close = list(1, 2), volume = list(0, 0))
  with_api(fx_payload(q, adjclose = list(0.9, 1.9)), {
    res <- currency_converter("EUR", "USD", period = "5d")
  })
  expect_equal(res$adj_close, c(0.9, 1.9))
  expect_equal(names(res), c("date", "high", "low", "open", "close", "volume", "adj_close"))
})

test_that("a NULL adjusted close inside the series becomes NA", {
  q <- list(open = list(1, 2), high = list(1, 2), low = list(1, 2),
            close = list(1, 2), volume = list(0, 0))
  with_api(fx_payload(q, adjclose = list(0.9, NULL)), {
    res <- currency_converter("EUR", "USD", period = "5d")
  })
  expect_equal(res$adj_close, c(0.9, NA))
})

test_that("omitted quote fields are NA instead of an error", {
  q <- list(close = list(1, 2), volume = list(0, 0))
  with_api(fx_payload(q), {
    res <- currency_converter("EUR", "USD", period = "5d")
  })
  expect_equal(nrow(res), 2)
  expect_true(all(is.na(res$open)))
  expect_equal(res$close, c(1, 2))
})

test_that("an empty chart result gives a typed empty tibble without warnings", {
  with_api(list(chart = list(result = NULL, error = NULL)), {
    expect_no_warning(res <- currency_converter())
  })
  expect_s3_class(res, "tbl_df")
  expect_equal(nrow(res), 0)
  expect_true(all(c("date", "close", "volume") %in% names(res)))
})
