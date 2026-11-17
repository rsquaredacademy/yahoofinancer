# Get Financial Statements

Retrieves quarterly or annual financial statements (income statement,
balance sheet, or cash flow) for one or more tickers.

## Usage

``` r
yf_get_financials(
  tickers,
  statement_type = c("income", "balance-sheet", "cash-flow"),
  frequency = c("annual", "quarterly")
)
```

## Arguments

- tickers:

  Character vector of stock symbols.

- statement_type:

  The type of financial statement to retrieve. One of `"income"`,
  `"balance-sheet"`, or `"cash-flow"`.

- frequency:

  One of `"annual"` or `"quarterly"`. Defaults to `"annual"`.

## Value

A [`tibble`](https://tibble.tidyverse.org/reference/tibble.html) with
`symbol` as the first column. Remaining columns vary by `statement_type`
and reflect the line items returned by the Yahoo Finance API. If all
tickers fail, returns a zero-row tibble with the columns `symbol`,
`date` and `period_type`.

## Examples

``` r
if (FALSE) { # \dontrun{
yf_get_financials("AAPL", statement_type = "income")
yf_get_financials(c("AAPL", "MSFT"), statement_type = "balance-sheet", frequency = "quarterly")
} # }
```
