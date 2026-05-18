# Implementation Plan: R6 Class Unification and API Consolidation

**Branch**: `r6-api-unification` | **Date**: 2026-05-18 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `specs/002-r6-api-unification/spec.md`

## Summary

The `Ticker` and `Index` R6 classes will be refactored to inherit from a unified `YahooFinanceBase` class that centralizes HTTP requests and `get_history` logic. We will implement an "Option B" soft-deprecation approach for the `Index` class, intercepting the old `index` parameter with a lifecycle warning and mapping it to `self$symbol`. Additionally, `flatten_list` and `get_metric` in `utils.R` will be consolidated into a single robust utility.

## Technical Context

**Language/Version**: R (>= 3.5.0)
**Primary Dependencies**: R6, httr, jsonlite, purrr, lubridate
**Storage**: N/A
**Testing**: testthat
**Target Platform**: Any
**Project Type**: R Package

## Project Structure

### Documentation
```text
specs/002-r6-api-unification/
├── plan.md
├── spec.md
└── tasks.md
```

### Source Code
```text
R/
├── base.R         # New file for YahooFinanceBase class
├── ticker.R       # Updated to inherit from YahooFinanceBase
├── indice.R       # Updated to inherit from YahooFinanceBase
└── utils.R        # Updated to consolidate utilities

tests/testthat/
├── test-ticker.R
├── test-index.R
├── test-utils.R
└── ...
```

## Option B Soft-Deprecation Approach

- **`YahooFinanceBase`**: A new R6 class (`R/base.R`) containing `self$symbol`, `initialize`, `set_symbol`, `get_history`, and a central private `api_request` method handling `httr::GET`, internet checks, and error parsing.
- **`Index` Interception**: `Index$initialize` will accept `index = NA, symbol = NA`. If `index` is provided, it throws `warning("The 'index' parameter is deprecated. Please use 'symbol' instead.")` and maps its value to `symbol`, then calls `super$initialize(symbol)`. A `set_index` wrapper will be kept with a similar warning mapping to `set_symbol`.
- **Utility Consolidation**: `flatten_list` and `get_metric` in `utils.R` will be merged into a single `flatten_list` function. All codebase calls to `get_metric` will be replaced with `flatten_list`.
