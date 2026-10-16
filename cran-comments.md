## Submission Summary (v0.6.1)

This is a patch release addressing:
* Financial statements restoration via fundamentals-timeseries endpoint
* Centralized and robust HTTP error handling with httr2
* Contract unification returning empty tibbles on multi-symbol failures
* Vectorized symbol validation and offline construction bypass
* Intraday lookback constraint enforcement and client-side date guards
* Code hygiene, styler formatting, and zero lintr findings

## Test environments

* local Windows 10 x64, R 4.5.2 (ucrt): `R CMD check --as-cran` on the built tarball
* win-builder (R-devel, 2026-10-16): 1 NOTE (see below)

## R CMD check results

0 errors | 0 warnings | 1 note

* Possibly invalid URL: https://finance.yahoo.com/ (DESCRIPTION), status 429 Too Many Requests.
  The URL is valid and opens normally in a browser; Yahoo rate-limits automated requests from
  check servers. It names the data source, so we would like to keep it.

## Reverse dependencies

There are no reverse dependencies on CRAN.

## Notes

Tests that call the Yahoo Finance web service are skipped on CRAN (`skip_on_cran()`); examples that need the network are wrapped in `\donttest{}`; offline tests use recorded fixtures.
