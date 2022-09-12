
<!-- README.md is generated from README.Rmd. Please edit that file -->

# yahoofinancer

<!-- badges: start -->

[![R-CMD-check](https://github.com/rsquaredacademy/yahoofinancer/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/rsquaredacademy/yahoofinancer/actions/workflows/R-CMD-check.yaml)
[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![Codecov test
coverage](https://codecov.io/gh/rsquaredacademy/yahoofinancer/branch/master/graph/badge.svg)](https://app.codecov.io/gh/rsquaredacademy/yahoofinancer?branch=master)
<!-- badges: end -->

The goal of yahoofinancer is to obtain historical and near real time
data related to stocks, index and currencies from the Yahoo Finance API.

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
aapl$get_history(start = '2022-09-01', interval = '1d')
#>                  date   volume   high    low   open  close adj_close
#> 1 2022-09-01 13:30:00 74229900 158.42 154.67 156.64 157.96    157.96
#> 2 2022-09-02 13:30:00 76905200 160.36 154.97 159.75 155.81    155.81
#> 3 2022-09-06 13:30:00 73714800 157.09 153.69 156.47 154.53    154.53
#> 4 2022-09-07 13:30:00 87449600 156.67 153.61 154.82 155.96    155.96
#> 5 2022-09-08 13:30:00 84923800 156.36 152.68 154.64 154.46    154.46
#> 6 2022-09-09 13:30:00 68028800 157.82 154.75 155.47 157.37    157.37
```

### Index

To retrieve data from Yahoo Finance for an index, create an instance of
the `Index` class by passing the index symbol as an argument:

``` r
nifty_50 <- Index$new('^NSEI')

# get historical data
nifty_50$get_history(start = '2022-09-01', interval = '1d')
#>                  date volume     high      low     open    close adj_close
#> 1 2022-09-01 03:45:00 308500 17695.60 17468.45 17485.70 17542.80  17542.80
#> 2 2022-09-02 03:45:00 256300 17643.85 17476.45 17598.40 17539.45  17539.45
#> 3 2022-09-05 03:45:00 230300 17683.15 17540.35 17546.45 17665.80  17665.80
#> 4 2022-09-06 03:45:00 251200 17764.65 17587.65 17695.70 17655.60  17655.60
#> 5 2022-09-07 03:45:00 354100 17650.75 17484.30 17519.40 17624.40  17624.40
#> 6 2022-09-08 03:45:00 279800 17807.65 17691.95 17748.15 17798.75  17798.75
#> 7 2022-09-09 03:45:00 270300 17925.95 17786.00 17923.35 17833.35  17833.35
#> 8 2022-09-12 06:20:57      0 17970.60 17889.15 17890.85 17952.60  17952.60
```

### Currency

``` r
currency_converter('GBP', 'USD', '2022-09-01', '2022-09-10')
#>                  date     high      low     open    close volume adj_close
#> 1 2022-08-31 23:00:00 1.161710 1.150324 1.159689 1.159851      0  1.159851
#> 2 2022-09-01 23:00:00 1.158856 1.153136 1.154734 1.154894      0  1.154894
#> 3 2022-09-04 23:00:00 1.152074 1.144518 1.147855 1.147460      0  1.147460
#> 4 2022-09-05 23:00:00 1.160766 1.149624 1.156885 1.156644      0  1.156644
#> 5 2022-09-06 23:00:00 1.152366 1.140953 1.151278 1.151185      0  1.151185
#> 6 2022-09-07 23:00:00 1.156016 1.146158 1.152246 1.151981      0  1.151981
#> 7 2022-09-08 23:00:00 1.164863 1.151662 1.152047 1.152160      0  1.152160
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
