# Get Market Statistics

Retrieves key real-time valuation and summary fields for one or more
tickers.

## Usage

``` r
yf_get_market_stats(tickers)
```

## Arguments

- tickers:

  Character vector of stock symbols.

## Value

A [`tibble`](https://tibble.tidyverse.org/reference/tibble.html) with 7
columns: `symbol` (character), `regular_market_price` (numeric),
`fifty_two_week_high` (numeric), `fifty_two_week_low` (numeric),
`regular_market_volume` (numeric), `previous_close` (numeric),
`currency` (character). Returns an empty tibble if all tickers fail.

## See also

Other market data:
[`get_market_summary()`](https://yahoofinancer.rsquaredacademy.com/reference/get_market_summary.md),
[`get_trending()`](https://yahoofinancer.rsquaredacademy.com/reference/get_trending.md)

## Examples

``` r
if (FALSE) { # \dontrun{
yf_get_market_stats("AAPL")
yf_get_market_stats(c("AAPL", "MSFT"))
} # }
```
