## Submission Summary (v0.6.2)

This is a patch release that fixes wrong results found in a pre-release audit of 0.6.1:

* `Ticker$valuation_measures` joins each metric by its own observation date (values could previously attach to the wrong quarter)
* `validate()` keeps symbols that contain dots (e.g. `VOD.L`) and matches the response by name
* `currency_converter()` no longer recycles a truncated adjusted-close series
* `Ticker` metadata cache is keyed by symbol
* Full-failure results of the functional API are typed zero-row tibbles with the documented columns
* The maintainer address is now aravindhebbali@rsquaredacademy.com; `jsonlite` moved from Imports to Suggests (package code does not use it)

## Test environments

* local Windows 11 x64, R 4.6.1 (ucrt): `R CMD check --as-cran --no-manual` on the built tarball

## R CMD check results

0 errors | 0 warnings | 1 note

* CRAN incoming feasibility: "New maintainer" (the maintainer address changed from hebbali.aravind@gmail.com to aravindhebbali@rsquaredacademy.com). The change is intentional; confirmation will be sent from the old address if CRAN asks.

## Reverse dependencies

There are no reverse dependencies on CRAN.

## Notes

The test suite is hermetic: a suite-wide setup file blocks the HTTP transport, so any request that is not mocked fails locally. The live smoke test (`test-smoke-live.R`) runs only when `YF_LIVE_TESTS=true`, so it never runs on CRAN. Examples that need the network are wrapped in `\dontrun{}`; offline tests use mocks and recorded httptest2 fixtures.
