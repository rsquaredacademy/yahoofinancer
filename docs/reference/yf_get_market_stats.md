# Get Market Statistics

Retrieves key valuation and summary fields for given tickers.

## Usage

``` r
yf_get_market_stats(tickers)
```

## Arguments

- tickers:

  Character vector of stock symbols.

## Value

A \`tibble\` of market statistics with \`symbol\` as the first column.

## Examples

``` r
# \donttest{
yf_get_market_stats("AAPL")
#> # A tibble: 1 × 7
#>   symbol regular_market_price fifty_two_week_high fifty_two_week_low
#>   <chr>                 <dbl>               <dbl>              <dbl>
#> 1 AAPL                   310.                345.               224.
#> # ℹ 3 more variables: regular_market_volume <int>, previous_close <dbl>,
#> #   currency <chr>
yf_get_market_stats(c("AAPL", "MSFT"))
#> # A tibble: 2 × 7
#>   symbol regular_market_price fifty_two_week_high fifty_two_week_low
#>   <chr>                 <dbl>               <dbl>              <dbl>
#> 1 AAPL                   310.                345.               224.
#> 2 MSFT                   482.                554.               349.
#> # ℹ 3 more variables: regular_market_volume <int>, previous_close <dbl>,
#> #   currency <chr>
# }
```
