
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
aapl$get_history(start = '2024-01-15', interval = '1d')
#>                   date   volume   high    low   open  close adj_close
#> 1  2024-01-16 14:30:00 65603000 184.26 180.93 182.16 183.63    183.63
#> 2  2024-01-17 14:30:00 47317400 182.93 180.30 181.27 182.68    182.68
#> 3  2024-01-18 14:30:00 78005800 189.14 185.83 186.09 188.63    188.63
#> 4  2024-01-19 14:30:00 68741000 191.95 188.82 189.33 191.56    191.56
#> 5  2024-01-22 14:30:00 60133900 195.33 192.26 192.30 193.89    193.89
#> 6  2024-01-23 14:30:00 42355600 195.75 193.83 195.02 195.18    195.18
#> 7  2024-01-24 14:30:00 53631300 196.38 194.34 195.42 194.50     194.5
#> 8  2024-01-25 14:30:00 54822100 196.27 193.11 195.22 194.17    194.17
#> 9  2024-01-26 14:30:00 44553400 194.76 191.94 194.27 192.42    192.42
#> 10 2024-01-29 14:30:00 47042500 192.20 189.58 192.01 191.73    191.73
```

### Index

To retrieve data from Yahoo Finance for an index, create an instance of
the `Index` class by passing the index symbol as an argument:

``` r
nifty_50 <- Index$new('^NSEI')

# get historical data
nifty_50$get_history(start = '2024-01-15', interval = '1d')
#>                   date volume     high      low     open    close adj_close
#> 1  2024-01-15 03:45:00 345500 22115.55 21963.55 22053.15 22097.45  22097.45
#> 2  2024-01-16 03:45:00 292400 22124.15 21969.80 22080.50 22032.30   22032.3
#> 3  2024-01-17 03:45:00 456000 21851.50 21550.45 21647.25 21571.95  21571.95
#> 4  2024-01-18 03:45:00 387300 21539.40 21285.55 21414.20 21462.25  21462.25
#> 5  2024-01-19 03:45:00 343100 21670.60 21575.00 21615.20 21622.40   21622.4
#> 6  2024-01-22 03:45:00     NA       NA       NA       NA       NA      NULL
#> 7  2024-01-23 03:45:00 449700 21750.25 21192.60 21716.70 21238.80   21238.8
#> 8  2024-01-24 03:45:00 407500 21482.35 21137.20 21185.25 21453.95  21453.95
#> 9  2024-01-25 03:45:00 418100 21459.00 21247.05 21454.60 21352.60   21352.6
#> 10 2024-01-29 03:45:00 376700 21763.25 21429.60 21433.10 21737.60   21737.6
#> 11 2024-01-30 07:40:04      0 21813.05 21655.25 21775.75 21674.95  21674.95
```

### Currency

``` r
currency_converter('GBP', 'USD', '2024-01-15', '2023-08-04')
#> Yahoo Finance API request failed
#> Status: 400
#> Type: Client error
#> Mesage: 
#> Description:
#> 
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
