
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
instance of the Ticker class by passing the company’s ticker symbol as
an argument:

``` r
aapl <- Ticker$new('aapl')

# get historical market data
head(aapl$get_history())
#>                  date    volume   high    low   open  close adj_close
#> 1 2022-01-03 14:30:00 104487900 182.88 177.71 177.83 182.01  181.2599
#> 2 2022-01-04 14:30:00  99310400 182.94 179.12 182.63 179.70  178.9595
#> 3 2022-01-05 14:30:00  94537600 180.17 174.64 179.61 174.92  174.1991
#> 4 2022-01-06 14:30:00  96904000 175.30 171.64 172.70 172.00  171.2912
#> 5 2022-01-07 14:30:00  86709100 174.14 171.03 172.89 172.17  171.4605
#> 6 2022-01-10 14:30:00 106765600 172.50 168.17 169.08 172.19  171.4804

# information available in summary tab in Yahoo Finance
aapl$summary_detail
#> $maxAge
#> [1] 1
#> 
#> $priceHint
#> [1] 2
#> 
#> $previousClose
#> [1] 167.23
#> 
#> $open
#> [1] 167.32
#> 
#> $dayLow
#> [1] 166.245
#> 
#> $dayHigh
#> [1] 167.59
#> 
#> $regularMarketPreviousClose
#> [1] 167.23
#> 
#> $regularMarketOpen
#> [1] 167.32
#> 
#> $regularMarketDayLow
#> [1] 166.245
#> 
#> $regularMarketDayHigh
#> [1] 167.59
#> 
#> $dividendRate
#> [1] 0.92
#> 
#> $dividendYield
#> [1] 0.0055
#> 
#> $exDividendDate
#> [1] 1659657600
#> 
#> $payoutRatio
#> [1] 0.1471
#> 
#> $fiveYearAvgDividendYield
#> [1] 1.05
#> 
#> $beta
#> [1] 1.230174
#> 
#> $trailingPE
#> [1] 27.62481
#> 
#> $forwardPE
#> [1] 25.95188
#> 
#> $volume
#> [1] 21074199
#> 
#> $regularMarketVolume
#> [1] 21074199
#> 
#> $averageVolume
#> [1] 75170682
#> 
#> $averageVolume10days
#> [1] 64089670
#> 
#> $averageDailyVolume10Day
#> [1] 64089670
#> 
#> $bid
#> [1] 166.59
#> 
#> $ask
#> [1] 166.4
#> 
#> $bidSize
#> [1] 1100
#> 
#> $askSize
#> [1] 1100
#> 
#> $marketCap
#> [1] 2.685914e+12
#> 
#> $fiftyTwoWeekLow
#> [1] 129.04
#> 
#> $fiftyTwoWeekHigh
#> [1] 182.94
#> 
#> $priceToSalesTrailing12Months
#> [1] 6.930641
#> 
#> $fiftyDayAverage
#> [1] 152.4194
#> 
#> $twoHundredDayAverage
#> [1] 160.6228
#> 
#> $trailingAnnualDividendRate
#> [1] 0.89
#> 
#> $trailingAnnualDividendYield
#> [1] 0.005322012
#> 
#> $currency
#> [1] "USD"
#> 
#> $tradeable
#> [1] FALSE
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
