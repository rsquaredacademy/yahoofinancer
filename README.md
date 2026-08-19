---
output: github_document
---

<!-- README.md is generated from README.Rmd. Please edit that file -->



# yahoofinancer

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/yahoofinancer)](https://CRAN.R-project.org/package=yahoofinancer)
[![R-CMD-check](https://github.com/rsquaredacademy/yahoofinancer/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/rsquaredacademy/yahoofinancer/actions/workflows/R-CMD-check.yaml)
[![Codecov test coverage](https://codecov.io/gh/rsquaredacademy/yahoofinancer/branch/master/graph/badge.svg)](https://app.codecov.io/gh/rsquaredacademy/yahoofinancer?branch=master)
<!-- badges: end -->

Obtain historical and near real time data related to stocks, index and currencies from the Yahoo Finance API.

## Installation


``` r
# Install yahoofinancer from CRAN
install.packages("yahoofinancer")

# Or the development version from GitHub
# install.packages("pak")
pak::pak("rsquaredacademy/yahoofinancer")
```

## Quick Start




### Ticker

To retrieve data from Yahoo Finance for a single stock, create an instance of the `Ticker` class by passing the company's ticker symbol as an argument:


``` r
aapl <- Ticker$new('aapl')

# get historical market data
head(aapl$get_history(start = '2024-10-20', interval = '1d'))
#> # A tibble: 6 × 8
#>   symbol date                 open  high   low close adj_close   volume
#>   <chr>  <dttm>              <dbl> <dbl> <dbl> <dbl>     <dbl>    <dbl>
#> 1 aapl   2024-10-21 13:30:00  234.  237.  234.  236.      235. 36254500
#> 2 aapl   2024-10-22 13:30:00  234.  236.  233.  236.      234. 38846600
#> 3 aapl   2024-10-23 13:30:00  234.  235.  228.  231.      229. 52287000
#> 4 aapl   2024-10-24 13:30:00  230.  231.  228.  231.      229. 31109500
#> 5 aapl   2024-10-25 13:30:00  230.  233.  230.  231.      229. 38802300
#> 6 aapl   2024-10-28 13:30:00  233.  235.  233.  233.      231. 36087100

# meta info
# regular market price
aapl$regular_market_price
#> [1] 310.03

# 52 week high
aapl$fifty_two_week_high
#> [1] 344.57

# previous close
aapl$previous_close
#> [1] 305.59
```

### Index 

To retrieve data from Yahoo Finance for an index, create an instance of the `Index` class by passing the index symbol as an argument:


``` r
nifty_50 <- Index$new('^NSEI')

# get historical data
head(nifty_50$get_history(start = '2024-01-20', interval = '1d'))
#> # A tibble: 6 × 8
#>   symbol date                  open   high    low  close adj_close volume
#>   <chr>  <dttm>               <dbl>  <dbl>  <dbl>  <dbl>     <dbl>  <dbl>
#> 1 ^NSEI  2024-01-23 03:45:00 21717. 21750. 21193. 21239.    21239. 449700
#> 2 ^NSEI  2024-01-24 03:45:00 21185. 21482. 21137. 21454.    21454. 407500
#> 3 ^NSEI  2024-01-25 03:45:00 21455. 21459  21247. 21353.    21353. 418100
#> 4 ^NSEI  2024-01-29 03:45:00 21433. 21763. 21430. 21738.    21738. 376700
#> 5 ^NSEI  2024-01-30 03:45:00 21776. 21813. 21502. 21522.    21522. 375100
#> 6 ^NSEI  2024-01-31 03:45:00 21487. 21741. 21449. 21726.    21726. 410600
```

### Currency


``` r
head(currency_converter('GBP', 'USD', '2024-01-20', '2024-01-30'))
#>         date     high      low     open    close volume adj_close
#> 1 2024-01-22 1.273075 1.268826 1.270083 1.269986      0  1.269986
#> 2 2024-01-23 1.274714 1.265534 1.270826 1.270696      0  1.270696
#> 3 2024-01-24 1.277368 1.268681 1.269422 1.269197      0  1.269197
#> 4 2024-01-25 1.274226 1.269293 1.271844 1.271876      0  1.271876
#> 5 2024-01-26 1.275754 1.267732 1.270696 1.270826      0  1.270826
#> 6 2024-01-29 1.271941 1.266320 1.269712 1.269761      0  1.269761
```

## IMPORTANT LEGAL DISCLAIMER 

**Yahoo!, Y!Finance, and Yahoo! finance are registered trademarks of
Yahoo, Inc.**

yahoofinancer is **not** affiliated, endorsed, or vetted by Yahoo, Inc. It's
an open-source tool that uses Yahoo's publicly available APIs, and is
intended for research and educational purposes.

**You should refer to Yahoo!'s terms of use**
([here](https://policies.yahoo.com/us/en/yahoo/terms/product-atos/apiforydn/index.htm),
[here](https://legal.yahoo.com/us/en/yahoo/terms/otos/index.html), and
[here](https://policies.yahoo.com/us/en/yahoo/terms/index.htm)) **for
details on your rights to use the actual data downloaded. Remember - the
Yahoo! finance API is intended for personal use only.**

## Code of Conduct

Please note that the yahoofinancer project is released with a [Contributor Code of Conduct](https://yahoofinancer.rsquaredacademy.com/CODE_OF_CONDUCT.html). By contributing to this project, you agree to abide by its terms.
