# yahoofinancer 0.5.0

## Bug Fixes

* Error in currency converter adjusted closing ([#21](https://github.com/rsquaredacademy/yahoofinancer/issues/21))
* Error in extracting historical values for stock ([#22](https://github.com/rsquaredacademy/yahoofinancer/issues/22))

## Enhancements
* **Multiple Tickers**: Get data for multiple tickers ([#19](https://github.com/rsquaredacademy/yahoofinancer/issues/19), [#20](https://github.com/rsquaredacademy/yahoofinancer/issues/20))
* **Unified Object Model**: Re-engineered duplicated code patterns by crafting a foundational `YahooFinanceBase` R6 parent class, modernizing object inheritance for `Ticker` and `Index` instances. ([#25](https://github.com/rsquaredacademy/yahoofinancer/pull/25))
* **API Lifecycle Layer**: Integrated an explicit parameter deprecation infrastructure to output clean soft-deprecation warnings while preserving structural backward compatibility.
* **Hermetic Test Suite**: Sealed the internal testing environment against ambient internet variables by enforcing local offline-only execution boundaries (`R_CHECK_INTERNET_AVAILABILITY=FALSE`).
* **Mock Path Optimization**: Flattened extended mock JSON directory structures beneath the 100-character POSIX threshold to guarantee absolute compatibility with CRAN tarball filters.

## Other Improvements
* **Environment Masking**: Appended specialized rules to `.Rbuildignore` to prevent local agent logs (`.gemini/`), unit metrics (`coverage.html`), and build directories (`lib/`) from leaking into release targets.
* **Repository Sanitation**: Cleaned out empty, legacy directory paths inside the testing footprint to preserve overall repository layout health.

# yahoofinancer 0.4.0

This is a minor release for bug fixes and other improvements.

## Bug Fixes

- all columns in valuation measures have same values([#13](https://github.com/rsquaredacademy/yahoofinancer/issues/13))
- incorrect api path used for quote([#14](https://github.com/rsquaredacademy/yahoofinancer/issues/14))
- error in options api([#15](https://github.com/rsquaredacademy/yahoofinancer/issues/15))

# yahoofinancer 0.3.0

This is a minor release for bug fixes:

- row mismatch ([#3](https://github.com/rsquaredacademy/yahoofinancer/issues/3))
- cran error ([#9](https://github.com/rsquaredacademy/yahoofinancer/issues/9))
- incorrect package alias ([#6](https://github.com/rsquaredacademy/yahoofinancer/issues/6))

# yahoofinancer 0.2.0

This is a minor release to fix bugs resulting from changes in Yahoo Finance API.

# yahoofinancer 0.1.0

- Added a `NEWS.md` file to track changes to the package.
