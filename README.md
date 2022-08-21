
<!-- README.md is generated from README.Rmd. Please edit that file -->

# yahoofinancer

<!-- badges: start -->
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
#> 2 2022-01-04 14:30:00  99310400 182.94 179.12 182.63 179.70  178.9594
#> 3 2022-01-05 14:30:00  94537600 180.17 174.64 179.61 174.92  174.1992
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
#> [1] 174.15
#> 
#> $open
#> [1] 173.03
#> 
#> $dayLow
#> [1] 171.3101
#> 
#> $dayHigh
#> [1] 173.74
#> 
#> $regularMarketPreviousClose
#> [1] 174.15
#> 
#> $regularMarketOpen
#> [1] 173.03
#> 
#> $regularMarketDayLow
#> [1] 171.3101
#> 
#> $regularMarketDayHigh
#> [1] 173.74
#> 
#> $dividendRate
#> [1] 0.92
#> 
#> $dividendYield
#> [1] 0.0054
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
#> [1] 28.35041
#> 
#> $forwardPE
#> [1] 26.63354
#> 
#> $volume
#> [1] 70346295
#> 
#> $regularMarketVolume
#> [1] 70346295
#> 
#> $averageVolume
#> [1] 76763275
#> 
#> $averageVolume10days
#> [1] 64119090
#> 
#> $averageDailyVolume10Day
#> [1] 64119090
#> 
#> $bid
#> [1] 170.71
#> 
#> $ask
#> [1] 170.75
#> 
#> $bidSize
#> [1] 900
#> 
#> $askSize
#> [1] 900
#> 
#> $marketCap
#> [1] 2.756464e+12
#> 
#> $fiftyTwoWeekLow
#> [1] 129.04
#> 
#> $fiftyTwoWeekHigh
#> [1] 182.94
#> 
#> $priceToSalesTrailing12Months
#> [1] 7.112684
#> 
#> $fiftyDayAverage
#> [1] 151.3188
#> 
#> $twoHundredDayAverage
#> [1] 160.461
#> 
#> $trailingAnnualDividendRate
#> [1] 0.89
#> 
#> $trailingAnnualDividendYield
#> [1] 0.005110537
#> 
#> $currency
#> [1] "USD"
#> 
#> $tradeable
#> [1] FALSE
```

## Legal Stuff

<table border="1" cellpadding="10">
<tr>
<td>

#### \*\*\* IMPORTANT LEGAL DISCLAIMER \*\*\*

------------------------------------------------------------------------

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

</td>
</tr>
</table>
