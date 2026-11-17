# H2: validate() keeps exact symbol keys, including dotted international tickers.

test_that("validate keeps dotted symbols alongside ordinary ones", {
  payload <- list(symbolsValidation = list(result = list(
    list(AAPL = TRUE), setNames(list(TRUE), "VOD.L")
  )))
  with_api(payload, {
    res <- validate(c("AAPL", "VOD.L"), return_logical = TRUE)
    expect_equal(res, c(AAPL = TRUE, VOD.L = TRUE))
    expect_equal(validate(c("AAPL", "VOD.L")), c("AAPL", "VOD.L"))
    tks <- Tickers$new(c("AAPL", "VOD.L"))
    expect_equal(tks$symbols, c("AAPL", "VOD.L"))
  })
})

test_that("validate maps a reordered response by name, not position", {
  payload <- list(symbolsValidation = list(result = list(
    list(MSFT = TRUE), list(NOTASTOCK = FALSE), setNames(list(TRUE), "BRK.B"), list(AAPL = TRUE)
  )))
  with_api(payload, {
    res <- validate(c("AAPL", "NOTASTOCK", "BRK.B", "MSFT"), return_logical = TRUE)
    expect_equal(res, c(AAPL = TRUE, NOTASTOCK = FALSE, BRK.B = TRUE, MSFT = TRUE))
  })
})

test_that("validate handles several symbols in one result object", {
  payload <- list(symbolsValidation = list(result = list(
    list(AAPL = TRUE, `RDS.A` = TRUE, NOPE = FALSE)
  )))
  with_api(payload, {
    res <- validate(c("NOPE", "RDS.A", "AAPL"), return_logical = TRUE)
    expect_equal(res, c(NOPE = FALSE, RDS.A = TRUE, AAPL = TRUE))
  })
})

test_that("validate marks a symbol absent from the response as invalid", {
  payload <- list(symbolsValidation = list(result = list(list(AAPL = TRUE))))
  with_api(payload, {
    res <- validate(c("AAPL", "MISSING.X"), return_logical = TRUE)
    expect_equal(res, c(AAPL = TRUE, MISSING.X = FALSE))
  })
})
