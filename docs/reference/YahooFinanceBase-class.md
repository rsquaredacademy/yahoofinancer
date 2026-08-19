# R6 Class Representing a Yahoo Finance Base Object

Base class for Ticker and Index classes.

## Format

An R6 class object

## Public fields

- `symbol`:

  Symbol for which data is retrieved.

## Methods

### Public methods

- [`YahooFinanceBase$new()`](#method-YahooFinanceBase-new)

- [`YahooFinanceBase$set_symbol()`](#method-YahooFinanceBase-set_symbol)

- [`YahooFinanceBase$get_history()`](#method-YahooFinanceBase-get_history)

- [`YahooFinanceBase$clone()`](#method-YahooFinanceBase-clone)

------------------------------------------------------------------------

### Method `new()`

Create a new YahooFinanceBase object.

#### Usage

    YahooFinanceBase$new(symbol = NA)

#### Arguments

- `symbol`:

  Symbol.

------------------------------------------------------------------------

### Method `set_symbol()`

Set a new symbol.

#### Usage

    YahooFinanceBase$set_symbol(symbol)

#### Arguments

- `symbol`:

  New symbol

------------------------------------------------------------------------

### Method `get_history()`

Retrieves historical pricing data from the Yahoo Finance chart API.

\*\*Intraday lookback limits\*\* (imposed by Yahoo Finance):

- `"1m"`: max 7 days

- `"5m"`, `"15m"`, `"30m"`: max 60 days

- `"1h"`: max 730 days

#### Usage

    YahooFinanceBase$get_history(
      period = "ytd",
      interval = "1d",
      start = NULL,
      end = NULL
    )

#### Arguments

- `period`:

  Length of time. Defaults to `'ytd'`. Valid values: `"1d"`, `"5d"`,
  `"1mo"`, `"3mo"`, `"6mo"`, `"1y"`, `"2y"`, `"5y"`, `"10y"`, `"ytd"`,
  `"max"`. Ignored when `start` is provided.

- `interval`:

  Time between data points. Defaults to `'1d'`. Valid values: `"1m"`,
  `"2m"`, `"5m"`, `"15m"`, `"30m"`, `"60m"`, `"90m"`, `"1h"`, `"1d"`,
  `"5d"`, `"1wk"`, `"1mo"`, `"3mo"`.

- `start`:

  Specific starting date. `String` or `Date` object in `"YYYY-MM-DD"`
  format.

- `end`:

  Specific ending date. `String` or `Date` object in `"YYYY-MM-DD"`
  format. Defaults to today when `start` is provided but `end` is
  `NULL`.

#### Returns

A [`tibble`](https://tibble.tidyverse.org/reference/tibble.html) with 8
columns:

- `symbol`:

  Character. Ticker symbol.

- `date`:

  POSIXct. Timestamp of the data point (UTC).

- `open`:

  Numeric. Opening price.

- `high`:

  Numeric. Period high.

- `low`:

  Numeric. Period low.

- `close`:

  Numeric. Closing price.

- `adj_close`:

  Numeric. Split- and dividend-adjusted close. Falls back to `close`
  when the API omits adjusted data.

- `volume`:

  Numeric. Trading volume.

Returns `invisible(NULL)` on network failure or invalid symbol.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    YahooFinanceBase$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
