# Download Historical Prices

Fetches historical OHLCV price data for one or more tickers using the
Yahoo Finance chart API. Results are combined into a single long-format
tibble suitable for `dplyr` pipelines.

\*\*Intraday lookback limits\*\* (imposed by Yahoo Finance):

- `"1m"`: max 7 days

- `"5m"`, `"15m"`, `"30m"`: max 60 days

- `"1h"`: max 730 days

## Usage

``` r
yf_download_prices(
  tickers,
  start = NULL,
  end = NULL,
  interval = "1d",
  period = NULL
)
```

## Arguments

- tickers:

  Character vector of one or more stock symbols (e.g.,
  `c("AAPL", "MSFT")`).

- start:

  Date or character string in `"YYYY-MM-DD"` format representing the
  start date. When provided, `period` is ignored.

- end:

  Date or character string in `"YYYY-MM-DD"` format representing the end
  date. Defaults to today if `start` is set but `end` is `NULL`.

- interval:

  Time between data points. Valid values: `"1m"`, `"2m"`, `"5m"`,
  `"15m"`, `"30m"`, `"60m"`, `"90m"`, `"1h"`, `"1d"`, `"5d"`, `"1wk"`,
  `"1mo"`, `"3mo"`. Defaults to `"1d"`.

- period:

  Relative time period. Valid values: `"1d"`, `"5d"`, `"1mo"`, `"3mo"`,
  `"6mo"`, `"1y"`, `"2y"`, `"5y"`, `"10y"`, `"ytd"`, `"max"`. Defaults
  to `"1y"` when both `start` and `period` are `NULL`.

## Value

A [`tibble`](https://tibble.tidyverse.org/reference/tibble.html) with 8
columns: `symbol`, `date`, `open`, `high`, `low`, `close`, `adj_close`,
`volume`. Returns an empty tibble if all tickers fail.

## See also

Other historical data:
[`Index-class`](https://yahoofinancer.rsquaredacademy.com/reference/Indice-class.md),
[`Ticker-class`](https://yahoofinancer.rsquaredacademy.com/reference/Ticker-class.md),
[`Tickers`](https://yahoofinancer.rsquaredacademy.com/reference/Tickers.md),
[`yf_get_index_quotes()`](https://yahoofinancer.rsquaredacademy.com/reference/yf_get_index_quotes.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Single ticker with date range
yf_download_prices("AAPL", start = "2023-01-01", end = "2023-01-10")

# Multiple tickers with relative period
yf_download_prices(c("AAPL", "MSFT"), period = "6mo", interval = "1mo")
} # }
```
