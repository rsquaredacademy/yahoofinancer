## Submission Summary (v0.6.1)

This is a patch release addressing:
* Financial statements restoration via fundamentals-timeseries endpoint
* Centralized and robust HTTP error handling with httr2
* Contract unification returning empty tibbles on multi-symbol failures
* Vectorized symbol validation and offline construction bypass
* Intraday lookback constraint enforcement and client-side date guards
* Code hygiene, styler formatting, and zero lintr findings

## R CMD check results

0 errors | 0 warnings | 0 notes

(Note: local offline check on Windows may report 1 NOTE "unable to verify current time" which resolves on connected CI runners).

## Test Environments

* local Windows 10 x64, R 4.5.2
* GitHub Actions: macOS (release), Windows (release), Ubuntu (devel, release, oldrel-1)

## Downstream Dependencies

* Checked reverse dependencies with 0 errors, 0 warnings, 0 notes.

