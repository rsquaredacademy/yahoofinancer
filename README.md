
<!-- README.md is generated from README.Rmd. Please edit that file -->

# yahoofinancer

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/yahoofinancer)](https://CRAN.R-project.org/package=yahoofinancer)
[![cran
checks](https://badges.cranchecks.info/summary/yahoofinancer.svg)](https://cran.r-project.org/web/checks/check_results_yahoofinancer.html)
[![R-CMD-check](https://github.com/rsquaredacademy/yahoofinancer/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/rsquaredacademy/yahoofinancer/actions/workflows/R-CMD-check.yaml)
[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![Codecov test
coverage](https://codecov.io/gh/rsquaredacademy/yahoofinancer/branch/master/graph/badge.svg)](https://app.codecov.io/gh/rsquaredacademy/yahoofinancer?branch=master)
[![status](https://tinyverse.netlify.com/badge/yahoofinancer)](https://CRAN.R-project.org/package=yahoofinancer)
<!-- badges: end -->

Obtain historical and near real time data related to stocks, index and
currencies from the Yahoo Finance API.

## Installation

You can install the development version of yahoofinancer from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("rsquaredacademy/yahoofinancer")
```

## Quick Start

### Ticker

To retrieve data from Yahoo Finance for a single stock, create an
instance of the `Ticker` class by passing the company’s ticker symbol as
an argument:

``` r
aapl <- Ticker$new('aapl')

# get historical market data
aapl$get_history(start = '2023-08-01', interval = '1d')
#>                  date    volume   high    low   open  close adj_close
#> 1 2023-08-01 13:30:00  35175100 196.73 195.28 196.24 195.61    195.61
#> 2 2023-08-02 13:30:00  50389300 195.18 191.85 195.04 192.58    192.58
#> 3 2023-08-03 13:30:00  61235200 192.37 190.69 191.57 191.17    191.17
#> 4 2023-08-04 13:30:00 115799700 187.38 181.92 185.52 181.99    181.99
#> 5 2023-08-07 13:50:28  19412704 183.13 178.80 182.13 178.93    178.93
```

### Index

To retrieve data from Yahoo Finance for an index, create an instance of
the `Index` class by passing the index symbol as an argument:

``` r
nifty_50 <- Index$new('^NSEI')

# get historical data
nifty_50$get_history(start = '2023-08-01', interval = '1d')
#>                  date volume     high      low     open    close adj_close
#> 1 2023-08-01 03:45:00 298000 19795.60 19704.60 19784.00 19733.55  19733.55
#> 2 2023-08-02 03:45:00 290700 19678.25 19423.55 19655.40 19526.55  19526.55
#> 3 2023-08-03 03:45:00 315700 19537.65 19296.45 19463.75 19381.65  19381.65
#> 4 2023-08-04 03:45:00 280800 19538.85 19436.45 19462.80 19517.00  19517.00
#> 5 2023-08-07 10:01:48      0 19620.45 19524.80 19576.85 19597.30  19597.30
```

### Currency

``` r
currency_converter('GBP', 'USD', '2023-08-01', '2023-08-04')
#>                  date     high      low     open    close volume adj_close
#> 1 2023-07-31 23:00:00 1.283862 1.274161 1.283203 1.283401      0  1.283401
#> 2 2023-08-01 23:00:00 1.279738 1.268183 1.279116 1.279574      0  1.279574
#> 3 2023-08-02 23:00:00 1.272848 1.262594 1.271763 1.272038      0  1.272038
#> 4 2023-08-03 23:00:00 1.278266 1.269164 1.271617 1.271634      0  1.271634
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
