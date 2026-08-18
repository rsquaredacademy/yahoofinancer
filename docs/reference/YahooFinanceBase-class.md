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

Retrieves historical pricing data.

#### Usage

    YahooFinanceBase$get_history(
      period = "ytd",
      interval = "1d",
      start = NULL,
      end = NULL
    )

#### Arguments

- `period`:

  Length of time. Defaults to `'ytd'`.

- `interval`:

  Time between data points. Defaults to `'1d'`.

- `start`:

  Specific starting date. `String` or `date` object.

- `end`:

  Specific ending date. `String` or `date` object.

#### Returns

A `data.frame`.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    YahooFinanceBase$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
