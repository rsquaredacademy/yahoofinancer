# Data Model: Test Coverage Hardening

This document outlines the core entities (R6 Classes) and utility functions targeted for test hardening, including their expected behaviors and edge cases.

## Core Entities

### Ticker (R6 Class)
- **Fields**:
  - `symbol`: Character (validated).
- **Public Methods**:
  - `get_history()`: Returns `data.frame`. Must handle missing `timestamp` in JSON.
  - `valuation_measures()`: Returns `data.frame`. Must handle empty `result` list.
  - `recommendations()`: Returns `data.frame`. Must handle empty `recommendedSymbols`.
  - `technical_insights()`: Returns `list`.
- **Validation Rules**:
  - `initialize()` and `set_symbol()` must call `validate()`.

### Index (R6 Class)
- **Fields**:
  - `index`: Character (validated).
- **Public Methods**:
  - `get_history()`: Returns `data.frame`. Must handle API errors and no-internet message.
- **Validation Rules**:
  - `initialize()` and `set_index()` must call `validate()`.

### Tickers (R6 Class)
- **Fields**:
  - `symbols`: Character vector.
  - `ticker_objs`: List of `Ticker` objects.
- **Public Methods**:
  - `aggregate_data(fn)`: Core aggregation logic. Must handle partial failures via `tryCatch`.

## Utility Functions

### validate(symbol)
- **Input**: Character.
- **Output**: Boolean.
- **Edge Cases**: `NULL`, no-internet, API error.

### flatten_list(x)
- **Input**: List.
- **Output**: Vector with `NA` for `NULL` elements.
- **Edge Cases**: `NULL` input, empty list.

### get_metric(data, metric)
- **Input**: List, Character.
- **Output**: Vector with `NA` for `NULL` elements.
- **Edge Cases**: Missing metric in list.

## Mock Data Models

### Chart API Error
```json
{
  "chart": {
    "error": {
      "code": "Not Found",
      "description": "Symbol not found"
    }
  }
}
```

### Empty Chart Data
```json
{
  "chart": {
    "result": [{
      "meta": { "currency": "USD" },
      "timestamp": null
    }]
  }
}
```
