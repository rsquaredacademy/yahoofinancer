
<!-- README.md is generated from README.Rmd. Please edit that file -->

# yahoofinancer

<!-- badges: start -->
<!-- badges: end -->

The goal of yahoofinancer is to obtain historical and near real time
data related to stocks, index and currencies from the Yahoo Finance API.

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

## Installation

You can install the development version of yahoofinancer from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("aravindhebbali/yahoofin")
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
#> 1 2022-01-03 14:30:00 104487900 182.88 177.71 177.83 182.01  181.5117
#> 2 2022-01-04 14:30:00  99310400 182.94 179.12 182.63 179.70  179.2080
#> 3 2022-01-05 14:30:00  94537600 180.17 174.64 179.61 174.92  174.4411
#> 4 2022-01-06 14:30:00  96904000 175.30 171.64 172.70 172.00  171.5291
#> 5 2022-01-07 14:30:00  86709100 174.14 171.03 172.89 172.17  171.6987
#> 6 2022-01-10 14:30:00 106765600 172.50 168.17 169.08 172.19  171.7186

# information available in summary tab in Yahoo Finance
aapl$summary_detail
#> $maxAge
#> [1] 1
#> 
#> $priceHint
#> [1] 2
#> 
#> $previousClose
#> [1] 151
#> 
#> $open
#> [1] 151.12
#> 
#> $dayLow
#> [1] 150.37
#> 
#> $dayHigh
#> [1] 153.72
#> 
#> $regularMarketPreviousClose
#> [1] 151
#> 
#> $regularMarketOpen
#> [1] 151.12
#> 
#> $regularMarketDayLow
#> [1] 150.37
#> 
#> $regularMarketDayHigh
#> [1] 153.72
#> 
#> $dividendRate
#> [1] 0.92
#> 
#> $dividendYield
#> [1] 0.0061
#> 
#> $exDividendDate
#> [1] 1651795200
#> 
#> $payoutRatio
#> [1] 0.1431
#> 
#> $fiveYearAvgDividendYield
#> [1] 1.07
#> 
#> $beta
#> [1] 1.19455
#> 
#> $trailingPE
#> [1] 24.88455
#> 
#> $forwardPE
#> [1] 23.50845
#> 
#> $volume
#> [1] 64823413
#> 
#> $regularMarketVolume
#> [1] 64823413
#> 
#> $averageVolume
#> [1] 93789221
#> 
#> $averageVolume10days
#> [1] 72599720
#> 
#> $averageDailyVolume10Day
#> [1] 72599720
#> 
#> $bid
#> [1] 0
#> 
#> $ask
#> [1] 0
#> 
#> $bidSize
#> [1] 2900
#> 
#> $askSize
#> [1] 800
#> 
#> $marketCap
#> [1] 2.476983e+12
#> 
#> $fiftyTwoWeekLow
#> [1] 129.04
#> 
#> $fiftyTwoWeekHigh
#> [1] 182.94
#> 
#> $priceToSalesTrailing12Months
#> [1] 6.416771
#> 
#> $fiftyDayAverage
#> [1] 143.1614
#> 
#> $twoHundredDayAverage
#> [1] 158.4493
#> 
#> $trailingAnnualDividendRate
#> [1] 0.88
#> 
#> $trailingAnnualDividendYield
#> [1] 0.005827814
#> 
#> $currency
#> [1] "USD"
#> 
#> $tradeable
#> [1] FALSE

# detailed pricing data
aapl$price
#> $maxAge
#> [1] 1
#> 
#> $preMarketChange
#> NULL
#> 
#> $preMarketPrice
#> NULL
#> 
#> $preMarketSource
#> [1] "FREE_REALTIME"
#> 
#> $postMarketChangePercent
#> [1] -0.00271167
#> 
#> $postMarketChange
#> $postMarketChange$raw
#> [1] -0.414993
#> 
#> $postMarketChange$fmt
#> [1] "-0.41"
#> 
#> 
#> $postMarketTime
#> [1] 1658361598
#> 
#> $postMarketPrice
#> $postMarketPrice$raw
#> [1] 152.625
#> 
#> $postMarketPrice$fmt
#> [1] "152.62"
#> 
#> 
#> $postMarketSource
#> NULL
#> 
#> $regularMarketChangePercent
#> [1] 0.01350989
#> 
#> $regularMarketChange
#> $regularMarketChange$raw
#> [1] 2.039993
#> 
#> $regularMarketChange$fmt
#> [1] "2.04"
#> 
#> 
#> $regularMarketTime
#> NULL
#> 
#> $priceHint
#> [1] 2
#> 
#> $regularMarketPrice
#> [1] 153.04
#> 
#> $regularMarketDayHigh
#> [1] 153.72
#> 
#> $regularMarketDayLow
#> [1] 150.37
#> 
#> $regularMarketVolume
#> $regularMarketVolume$raw
#> [1] 64823413
#> 
#> $regularMarketVolume$fmt
#> [1] "64.82M"
#> 
#> $regularMarketVolume$longFmt
#> [1] "64,823,413.00"
#> 
#> 
#> $averageDailyVolume10Day
#> named list()
#> 
#> $averageDailyVolume3Month
#> NULL
#> 
#> $regularMarketPreviousClose
#> $regularMarketPreviousClose$raw
#> [1] 151
#> 
#> $regularMarketPreviousClose$fmt
#> [1] "151.00"
#> 
#> 
#> $regularMarketSource
#> NULL
#> 
#> $regularMarketOpen
#> $regularMarketOpen$raw
#> [1] 151.12
#> 
#> $regularMarketOpen$fmt
#> [1] "151.12"
#> 
#> 
#> $strikePrice
#> named list()
#> 
#> $openInterest
#> named list()
#> 
#> $exchange
#> [1] "NMS"
#> 
#> $exchangeName
#> [1] "NasdaqGS"
#> 
#> $exchangeDataDelayedBy
#> [1] 0
#> 
#> $marketState
#> [1] "PREPRE"
#> 
#> $quoteType
#> [1] "EQUITY"
#> 
#> $symbol
#> [1] "AAPL"
#> 
#> $underlyingSymbol
#> NULL
#> 
#> $shortName
#> [1] "Apple Inc."
#> 
#> $longName
#> [1] "Apple Inc."
#> 
#> $currency
#> [1] "USD"
#> 
#> $quoteSourceName
#> [1] "Nasdaq Real Time Price"
#> 
#> $currencySymbol
#> [1] "$"
#> 
#> $fromCurrency
#> NULL
#> 
#> $toCurrency
#> NULL
#> 
#> $lastMarket
#> NULL
#> 
#> $volume24Hr
#> named list()
#> 
#> $volumeAllCurrencies
#> named list()
#> 
#> $circulatingSupply
#> NULL
#> 
#> $marketCap
#> $marketCap$raw
#> [1] 2.476983e+12
#> 
#> $marketCap$fmt
#> [1] "2.48T"
#> 
#> $marketCap$longFmt
#> [1] "2,476,982,927,360.00"
```

## Legal Stuff

yahoofinancer is **not** affiliated, endorsed, or vetted by Yahoo,
Inc. It’s an open-source tool that uses Yahoo’s publicly available APIs,
and is intended for research and educational purposes. You should refer
to Yahoo!’s terms of use
([here](https://policies.yahoo.com/us/en/yahoo/terms/product-atos/apiforydn/index.htm),
[here](https://legal.yahoo.com/us/en/yahoo/terms/otos/index.html), and
[here](https://policies.yahoo.com/us/en/yahoo/terms/index.htm)) for
detailes on your rights to use the actual data downloaded.
