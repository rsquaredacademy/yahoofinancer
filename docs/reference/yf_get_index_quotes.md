# Get Index Quotes

Retrieves the most recent 1-day price snapshot for a given market index.

## Usage

``` r
yf_get_index_quotes(index_symbol)
```

## Arguments

- index_symbol:

  Character string of the index symbol (e.g., `"^GSPC"` for S&P 500,
  `"^NSEI"` for Nifty 50).

## Value

A [`tibble`](https://tibble.tidyverse.org/reference/tibble.html) with
the same 8-column schema as
[`yf_download_prices`](https://yahoofinancer.rsquaredacademy.com/reference/yf_download_prices.md):
`symbol`, `date`, `open`, `high`, `low`, `close`, `adj_close`, `volume`.
Returns an empty tibble on failure.

## See also

Other historical data:
[`Indice-class`](https://yahoofinancer.rsquaredacademy.com/reference/Indice-class.md),
[`Ticker-class`](https://yahoofinancer.rsquaredacademy.com/reference/Ticker-class.md),
[`Tickers`](https://yahoofinancer.rsquaredacademy.com/reference/Tickers.md),
[`yf_download_prices()`](https://yahoofinancer.rsquaredacademy.com/reference/yf_download_prices.md)

## Examples

``` r
if (FALSE) { # \dontrun{
yf_get_index_quotes("^GSPC")
} # }
```
