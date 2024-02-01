test_that("output from validate is as expected", {
  testthat::skip_on_cran()
  expect_true(validate("aapl"))
})

test_that("output from validate is as expected when symbol is wrong", {
  testthat::skip_on_cran()
  expect_false(validate("aapls"))
})
