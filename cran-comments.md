## Submission Summary (v0.6.2)

This is a patch release that fixes wrong results found in a pre-release audit of 0.6.1:

* `Ticker$valuation_measures` joins each metric by its own observation date (values could previously attach to the wrong quarter)
* `validate()` keeps symbols that contain dots (e.g. `VOD.L`) and matches the response by name case-insensitively, preserving the caller's spelling and order
* `currency_converter()` no longer recycles a truncated adjusted-close series
* `Ticker` metadata cache is keyed by symbol
* Full-failure results of the functional API are typed zero-row tibbles with the documented columns
* The maintainer address is now aravindhebbali@rsquaredacademy.com; `jsonlite` remains in Imports because `httr2::resp_body_json()` requires it at runtime (no NAMESPACE import is needed)
* Non-object JSON bodies and malformed endpoint envelopes warn and return NULL; error diagnostics preserve the full condition message

## Test environments

* local Windows 11 x64, R 4.6.1 (ucrt): `R CMD check --as-cran --no-manual` on the built tarball

## R CMD check results

0 errors | 0 warnings | 1 note

* CRAN incoming feasibility: "New maintainer" (the maintainer address changed from hebbali.aravind@gmail.com to aravindhebbali@rsquaredacademy.com). The change is intentional; confirmation will be sent from the old address if CRAN asks.

## Reverse dependencies

There are no reverse dependencies on CRAN.

## Notes

The default test suite is hermetic: a suite-wide setup file blocks the HTTP transport, so any request that is not mocked fails locally. Explicitly setting `YF_LIVE_TESTS=true` bypasses both the transport blocker and the forced connectivity binding and enables the live smoke test (`test-smoke-live.R`); CRAN does not opt in. Examples that need the network are wrapped in `\dontrun{}`; offline tests use mocks and recorded httptest2 fixtures.
