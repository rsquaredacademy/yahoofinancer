# Download Historical Prices

Fetches historical price data for single or multiple tickers.

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

  Character vector of stock symbols.

- start:

  Date or character string representing the start date (\`YYYY-MM-DD\`).

- end:

  Date or character string representing the end date (\`YYYY-MM-DD\`).

- interval:

  Time between data points (e.g., "1d", "1wk", "1mo").

- period:

  Relative time period for data retrieval (e.g., "1mo", "1y", "max").
  Valid values are "1d", "5d", "1mo", "3mo", "6mo", "1y", "2y", "5y",
  "10y", "ytd", "max". Defaults to "1y" if both \`start\` and \`period\`
  are NULL.

## Value

A \`tibble\` of historical prices with \`symbol\` as the first column.

## Examples

``` r
# \donttest{
yf_download_prices("AAPL", start = "2023-01-01", end = "2023-01-10")
#> # A tibble: 5 × 8
#>   symbol date                 open  high   low close adj_close    volume
#>   <chr>  <dttm>              <dbl> <dbl> <dbl> <dbl>     <dbl>     <dbl>
#> 1 AAPL   2023-01-03 14:30:00  130.  131.  124.  125.      123. 112117500
#> 2 AAPL   2023-01-04 14:30:00  127.  129.  125.  126.      124.  89113600
#> 3 AAPL   2023-01-05 14:30:00  127.  128.  125.  125.      123.  80962700
#> 4 AAPL   2023-01-06 14:30:00  126.  130.  125.  130.      127.  87754700
#> 5 AAPL   2023-01-09 14:30:00  130.  133.  130.  130.      128.  70790800
yf_download_prices(c("AAPL", "MSFT"), period = "6mo", interval = "1mo")
#> # A tibble: 14 × 8
#>    symbol date                 open  high   low close adj_close     volume
#>    <chr>  <dttm>              <dbl> <dbl> <dbl> <dbl>     <dbl>      <dbl>
#>  1 AAPL   2026-03-01 05:00:00  262.  267.  246.  254.      253.  900035700
#>  2 AAPL   2026-04-01 04:00:00  254.  276   246.  271.      271.  907538500
#>  3 AAPL   2026-05-01 04:00:00  279.  315   275.  312.      312.  981286400
#>  4 AAPL   2026-06-01 04:00:00  310.  317.  274.  289.      289. 1401170100
#>  5 AAPL   2026-07-01 04:00:00  293.  345.  289.  309.      309. 1198861200
#>  6 AAPL   2026-08-01 04:00:00  310.  316.  301.  306.      306.  465551900
#>  7 AAPL   2026-08-18 15:59:30  308.  311.  306.  310.      310.   19723811
#>  8 MSFT   2026-03-01 05:00:00  393.  413.  356.  370.      369.  745288400
#>  9 MSFT   2026-04-01 04:00:00  373.  434.  364.  408.      407.  716519100
#> 10 MSFT   2026-05-01 04:00:00  413.  450.  401.  450.      450.  698954800
#> 11 MSFT   2026-06-01 04:00:00  465.  466.  349.  373.      373. 1017814300
#> 12 MSFT   2026-07-01 04:00:00  381.  467.  373.  465.      465.  815118000
#> 13 MSFT   2026-08-01 04:00:00  476.  514.  475   495.      495.  338395800
#> 14 MSFT   2026-08-18 15:59:30  482.  484.  477.  482.      482.    7787969
# }
```
