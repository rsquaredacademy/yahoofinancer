# Get Real-Time Market Summary

Retrieve live market overview snapshots across global benchmark indices,
commodities, currencies, and futures.

## Usage

``` r
get_market_summary(as_tibble = TRUE)
```

## Arguments

- as_tibble:

  Logical; if `TRUE` (default), returns a tidy tibble. If `FALSE`,
  returns the raw nested list from the API.

## Value

If `as_tibble = TRUE`, a
[`tibble`](https://tibble.tidyverse.org/reference/tibble.html) with 9
columns: `symbol`, `short_name`, `regular_market_price`,
`regular_market_change`, `regular_market_change_percent`,
`regular_market_previous_close`, `market_state`, `exchange`,
`market_time` (POSIXct, UTC). If `as_tibble = FALSE`, a nested list.
Returns an empty tibble (or `invisible(NULL)`) on failure.

## See also

Other market data:
[`get_trending()`](https://yahoofinancer.rsquaredacademy.com/reference/get_trending.md),
[`yf_get_market_stats()`](https://yahoofinancer.rsquaredacademy.com/reference/yf_get_market_stats.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Tidy tibble output (default)
market_df <- get_market_summary()

# Raw list output
market_list <- get_market_summary(as_tibble = FALSE)
} # }
```
