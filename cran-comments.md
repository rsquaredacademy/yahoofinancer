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
* win-builder (R-devel): to be run by the maintainer before submission

## R CMD check results

0 errors | 0 warnings | 0 notes

## Reverse dependencies

There are no reverse dependencies on CRAN.

## Notes

Tests that call the Yahoo Finance web service are skipped on CRAN (`skip_on_cran()`); examples that need the network are wrapped in `\donttest{}`; offline tests use recorded fixtures.
