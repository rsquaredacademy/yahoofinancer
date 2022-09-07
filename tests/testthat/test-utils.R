test_that("output from validate is as expected", {
  expect_true(validate("aapl"))
})

test_that("output from validate is as expected when symbol is wrong", {
  expect_false(validate("aapls"))
})
