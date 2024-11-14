
<!-- README.md is generated from README.Rmd. Please edit that file -->

# yahoofinancer

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/yahoofinancer)](https://CRAN.R-project.org/package=yahoofinancer)
[![R-CMD-check](https://github.com/rsquaredacademy/yahoofinancer/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/rsquaredacademy/yahoofinancer/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/rsquaredacademy/yahoofinancer/branch/master/graph/badge.svg)](https://app.codecov.io/gh/rsquaredacademy/yahoofinancer?branch=master)
<!-- badges: end -->

Obtain historical and near real time data related to stocks, index and
currencies from the Yahoo Finance API.

## Installation

``` r
# Install rfm from CRAN
install.packages("yahoofinancer")

# Or the development version from GitHub
# install.packages("pak")
pak::pak("rsquaredacademy/yahoofinancer")
```

## Quick Start

### Ticker

To retrieve data from Yahoo Finance for a single stock, create an
instance of the `Ticker` class by passing the company’s ticker symbol as
an argument:

``` r
aapl <- Ticker$new('aapl')

# get historical market data
head(aapl$get_history(start = '2024-01-20', interval = '1d'))
#>                  date   volume   high    low   open  close adj_close
#> 1 2024-01-22 14:30:00 60133900 195.33 192.26 192.30 193.89  192.9447
#> 2 2024-01-23 14:30:00 42355600 195.75 193.83 195.02 195.18  194.2285
#> 3 2024-01-24 14:30:00 53631300 196.38 194.34 195.42 194.50  193.5518
#> 4 2024-01-25 14:30:00 54822100 196.27 193.11 195.22 194.17  193.2234
#> 5 2024-01-26 14:30:00 44594000 194.76 191.94 194.27 192.42  191.4819
#> 6 2024-01-29 14:30:00 47145600 192.20 189.58 192.01 191.73  190.7953

# meta info
# regular market price
aapl$regular_market_price
#> [1] 225.46

# 52 week high
aapl$fifty_two_week_high
#> [1] 237.49

# previous close
aapl$previous_close
#> [1] 225.12
```

### Index

To retrieve data from Yahoo Finance for an index, create an instance of
the `Index` class by passing the index symbol as an argument:

``` r
nifty_50 <- Index$new('^NSEI')

# get historical data
head(nifty_50$get_history(start = '2024-01-20', interval = '1d'))
#>                  date volume     high      low     open    close adj_close
#> 1 2024-01-23 03:45:00 449700 21750.25 21192.60 21716.70 21238.80   21238.8
#> 2 2024-01-24 03:45:00 407500 21482.35 21137.20 21185.25 21453.95  21453.95
#> 3 2024-01-25 03:45:00 418100 21459.00 21247.05 21454.60 21352.60   21352.6
#> 4 2024-01-29 03:45:00 376700 21763.25 21429.60 21433.10 21737.60   21737.6
#> 5 2024-01-30 03:45:00 375100 21813.05 21501.80 21775.75 21522.10   21522.1
#> 6 2024-01-31 03:45:00 410600 21741.35 21448.85 21487.25 21725.70   21725.7
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

yahoofinancer is **not** affiliated, endorsed, or vetted by Yahoo,
Inc. It’s an open-source tool that uses Yahoo’s publicly available APIs,
and is intended for research and educational purposes.

**You should refer to Yahoo!’s terms of use**
([here](https://policies.yahoo.com/us/en/yahoo/terms/product-atos/apiforydn/index.htm),
[here](https://legal.yahoo.com/us/en/yahoo/terms/otos/index.html), and
[here](https://policies.yahoo.com/us/en/yahoo/terms/index.htm)) **for
details on your rights to use the actual data downloaded. Remember - the
Yahoo! finance API is intended for personal use only.**

## Code of Conduct

Please note that the yahoofinancer project is released with a
[Contributor Code of
Conduct](https://yahoofinancer.rsquaredacademy.com/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.
