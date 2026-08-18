if (requireNamespace("httptest2", quietly = TRUE)) {
  # Shorten URL paths to prevent CRAN NOTE (file path > 100 bytes)
  httptest2::set_redactor(function(resp) {
    if (!is.null(resp$url)) {
      resp$url <- gsub("query[12]\\.finance\\.yahoo\\.com/v[0-9]+/finance/", "api/", resp$url)
      resp$url <- gsub("query[12]\\.finance\\.yahoo\\.com/ws/insights/v[0-9]+/finance/", "api/ins/", resp$url)
      resp$url <- gsub("quote/marketSummary", "mkt", resp$url)
      resp$url <- gsub("quoteSummary", "qs", resp$url)
      resp$url <- gsub("chart", "chr", resp$url)
      resp$url <- gsub("quote", "qt", resp$url)
      resp$url <- gsub("trending", "trnd", resp$url)
      resp$url <- gsub("options", "opt", resp$url)
    }
    resp
  })
}
