test_that("canonical keys match lower and mixed case without losing identity or order", {
  body <- '{"symbolsValidation":{"result":[{"MSFT":false},{"BRK.B":true},
    {"VOD.L":true},{"AAPL":true}]}}'
  syms <- c("aapl", "vod.l", "mSfT", "BrK.b", "VoD.L", "VOD-L", "aapl", NA)
  with_json_response(body, {
    expect_equal(validate(syms, return_logical = TRUE),
                 setNames(c(TRUE, TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, FALSE), syms))
    expect_equal(validate(syms), c("aapl", "vod.l", "BrK.b", "VoD.L", "aapl"))
    expect_equal(Ticker$new("vod.l")$symbol, "vod.l")
    expect_equal(Tickers$new(c("aapl", "BrK.b"))$symbols, c("aapl", "BrK.b"))
  })
})

test_that("recorded canonical AAPL validates lowercase and the README constructor", {
  with_json_response(recorded_json("qt", "validate-2aa074.json"), {
    expect_equal(validate("aapl", return_logical = TRUE), c(aapl = TRUE))
    expect_equal(Ticker$new("aapl")$symbol, "aapl")
    # Replay the constructor from the shipped README; README.Rmd is its source.
    readme <- test_path("..", "..", "README.md")
    if (file.exists(readme)) {
      constructor <- grep('^aapl <- Ticker', readLines(readme, warn = FALSE), value = TRUE)
      expect_length(constructor, 1L)
      env <- new.env()
      eval(parse(text = constructor), envir = env)
      expect_equal(env$aapl$symbol, "aapl")
    }
  })
})
