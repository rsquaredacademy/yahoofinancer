# R6 Class Representing a Ticker

Class for retrieving all data related to a single ticker from the Yahoo
Finance API. Inherits `get_history()` from
[`YahooFinanceBase-class`](https://yahoofinancer.rsquaredacademy.com/reference/YahooFinanceBase-class.md).

## Format

An R6 class object

## See also

Other historical data:
[`Indice-class`](https://yahoofinancer.rsquaredacademy.com/reference/Indice-class.md),
[`Tickers`](https://yahoofinancer.rsquaredacademy.com/reference/Tickers.md),
[`yf_download_prices()`](https://yahoofinancer.rsquaredacademy.com/reference/yf_download_prices.md),
[`yf_get_index_quotes()`](https://yahoofinancer.rsquaredacademy.com/reference/yf_get_index_quotes.md)

## Super class

[`yahoofinancer::YahooFinanceBase`](https://yahoofinancer.rsquaredacademy.com/reference/YahooFinanceBase-class.md)
-\> `Ticker`

## Active bindings

- `valuation_measures`:

  Retrieves valuation measures

- `recommendations`:

  Related symbols recommended by Yahoo Finance and their scores.

- `technical_insights`:

  Technical insights and indicators snapshot.

- `currency`:

  Currency code for the symbol.

- `exchange_name`:

  Short name of the stock exchange.

- `full_exchange_name`:

  Full name of the stock exchange.

- `first_trade_date`:

  Timestamp of the first recorded trade.

- `regular_market_time`:

  Timestamp of the last market trade.

- `timezone`:

  Timezone code of the exchange.

- `exchange_timezone_name`:

  Full timezone name of the exchange.

- `regular_market_price`:

  Current regular market price.

- `fifty_two_week_high`:

  52-week high price.

- `fifty_two_week_low`:

  52-week low price.

- `regular_market_day_high`:

  Highest price during the current trading session.

- `regular_market_day_low`:

  Lowest price during the current trading session.

- `regular_market_volume`:

  Current trading volume.

- `previous_close`:

  Closing price of the previous trading day.

## Methods

### Public methods

- [`Ticker$clone()`](#method-Ticker-clone)

Inherited methods

- [`yahoofinancer::YahooFinanceBase$get_history()`](https://yahoofinancer.rsquaredacademy.com/reference/YahooFinanceBase.html#method-get_history)
- [`yahoofinancer::YahooFinanceBase$initialize()`](https://yahoofinancer.rsquaredacademy.com/reference/YahooFinanceBase.html#method-initialize)
- [`yahoofinancer::YahooFinanceBase$set_symbol()`](https://yahoofinancer.rsquaredacademy.com/reference/YahooFinanceBase.html#method-set_symbol)

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    Ticker$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
