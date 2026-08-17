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
