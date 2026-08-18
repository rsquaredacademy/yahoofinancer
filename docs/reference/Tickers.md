# Multi-Symbol Ticker Data Aggregator

An R6 class to manage and aggregate data from multiple Yahoo Finance
tickers simultaneously. It wraps the `Ticker` class to provide a
unified, long-format data interface suitable for bulk analysis and
visualization.

## Details

The `Tickers` class automates the process of iterating over a vector of
symbols. It handles per-symbol errors gracefully via an internal
`aggregate_data` helper, ensuring that a failure in one symbol does not
prevent the collection of data for others.

Most properties return a `data.frame` where the first column is
`symbol`, facilitating easy filtering and joining in tidy workflows.

## Public fields

- `symbols`:

  A unique character vector of symbols being tracked.

- `ticker_objs`:

  A named list of underlying `Ticker` R6 objects.

## Active bindings

- `recommendations`:

  Related symbols suggested by Yahoo Finance and their relevance scores.

- `valuation_measures`:

  Quarterly valuation statistics including PE and Enterprise Value.

- `technical_insights`:

  Technical indicator snapshots (e.g., RSI, Moving Averages).

- `regular_market_price`:

  The current market price for each symbol.

- `regular_market_time`:

  The timestamp of the last market trade.

- `regular_market_volume`:

  The current trading volume.

- `regular_market_day_high`:

  The highest price during the current trading session.

- `regular_market_day_low`:

  The lowest price during the current trading session.

- `previous_close`:

  The closing price of the previous trading day.

- `fifty_two_week_high`:

  The highest price over the last 52 weeks.

- `fifty_two_week_low`:

  The lowest price over the last 52 weeks.

- `currency`:

  The currency code (e.g., "USD") for the symbols.

- `exchange_name`:

  The short name of the stock exchange.

- `full_exchange_name`:

  The full name of the stock exchange.

- `first_trade_date`:

  The Unix timestamp of the first recorded trade.

- `timezone`:

  The timezone code (e.g., "EDT").

- `exchange_timezone_name`:

  The full name of the exchange's timezone.

## Methods

### Public methods

- [`Tickers$new()`](#method-Tickers-new)

- [`Tickers$get_history()`](#method-Tickers-get_history)

- [`Tickers$aggregate_data()`](#method-Tickers-aggregate_data)

- [`Tickers$clone()`](#method-Tickers-clone)

------------------------------------------------------------------------

### Method `new()`

Create a new Tickers object.

#### Usage

    Tickers$new(symbols)

#### Arguments

- `symbols`:

  A character vector of Yahoo Finance ticker symbols.

#### Returns

A new `Tickers` object.

------------------------------------------------------------------------

### Method `get_history()`

Retrieve historical market data for all symbols.

#### Usage

    Tickers$get_history(period = "1y", interval = "1d", start = NULL, end = NULL)

#### Arguments

- `period`:

  The duration of history to fetch; "1d", "5d", "1mo", "1y", "max" etc.

- `interval`:

  The frequency of data points; "1m", "2m", "5m", "1h", "1d", "1wk" etc.

- `start`:

  Date or timestamp for the start of the period.

- `end`:

  Date or timestamp for the end of the period.

#### Returns

A tidy `data.frame` containing historical prices and volumes.

------------------------------------------------------------------------

### Method `aggregate_data()`

Internal helper to execute a method across all symbols and combine
results.

#### Usage

    Tickers$aggregate_data(fn)

#### Arguments

- `fn`:

  A function or anonymous function that takes a `Ticker` object.

#### Returns

A combined `data.frame` or `NULL`.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    Tickers$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
# Initialize for a set of tech stocks
stocks <- Tickers$new(c("AAPL", "MSFT", "GOOGL"))

# 1. Get 1 month of historical daily prices
hist_data <- stocks$get_history(period = "1mo", interval = "1d")
head(hist_data)

# 2. Get current market prices for the group
current_prices <- stocks$regular_market_price

# 3. View recommended related symbols and scores
recs <- stocks$recommendations

# 4. Get technical insights (RSI, Moving Averages)
tech <- stocks$technical_insights
} # }
```
