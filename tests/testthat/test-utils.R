library(testthat)
library(yahoofinancer)

test_that("flatten_list handles edge cases", {
  # NULL input
  expect_null(flatten_list(NULL))
  
  # Empty list
  expect_null(flatten_list(list()))
  
  # List with NULLs
  expect_equal(flatten_list(list(1, NULL, 3)), c(1, NA, 3))
  
  # List with all NULLs
  expect_equal(flatten_list(list(NULL, NULL)), as.logical(c(NA, NA)))
})

test_that("parse_chart_data handles missing quote fields and adj_close mismatch", {
  dummy_data <- list(
    timestamp = list(1625059200, 1625145600),
    indicators = list(
      quote = list(list(
        open = list(100, 101),
        close = list(102, 103)
        # high, low, volume missing
      )),
      adjclose = list(list(
        adjclose = list(102) # length 1 vs timestamps length 2
      ))
    )
  )

  expect_warning(
    res <- parse_chart_data(dummy_data, "TEST"),
    "Adjusted close length does not match timestamps"
  )
  expect_s3_class(res, "tbl_df")
  expect_equal(nrow(res), 2)
  expect_equal(res$open, c(100, 101))
  expect_equal(res$close, c(102, 103))
  expect_equal(res$adj_close, c(102, 103))
  expect_true(all(is.na(res$high)))
  expect_true(all(is.na(res$low)))
  expect_true(all(is.na(res$volume)))
})
