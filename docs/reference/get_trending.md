# Get Trending Securities

Retrieves the list of currently trending securities for a specific
region from Yahoo Finance.

## Usage

``` r
get_trending(country = "US", count = 10)
```

## Arguments

- country:

  ISO 3166-1 alpha-2 region code (e.g., `"US"`, `"GB"`, `"IN"`).
  Defaults to `"US"`.

- count:

  Maximum number of trending securities to return. Defaults to `10`.

## Value

A character vector of trending ticker symbols. Returns `invisible(NULL)`
on network failure or if no data is available (with a message).

## See also

Other market data:
[`get_market_summary()`](https://yahoofinancer.rsquaredacademy.com/reference/get_market_summary.md),
[`yf_get_market_stats()`](https://yahoofinancer.rsquaredacademy.com/reference/yf_get_market_stats.md)

## Examples

``` r
if (FALSE) { # \dontrun{
get_trending()
get_trending(country = "GB", count = 5)
} # }
```
