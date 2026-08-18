# Get Financial Statements

Retrieves financial statements (income statement, balance sheet, or cash
flow) for given tickers.

## Usage

``` r
yf_get_financials(
  tickers,
  statement_type = c("income", "balance-sheet", "cash-flow")
)
```

## Arguments

- tickers:

  Character vector of stock symbols.

- statement_type:

  The type of financial statement to retrieve. One of "income",
  "balance-sheet", or "cash-flow".

## Value

A \`tibble\` of financial data with \`symbol\` as the first column.

## Examples

``` r
# \donttest{
yf_get_financials("AAPL", statement_type = "income")
#> Warning: Failed to fetch data for ticker: AAPL
#> # A tibble: 0 × 0
# }
```
