## Submission Summary (v0.6.1)

This is a patch release addressing:
* Financial statements restoration via fundamentals-timeseries endpoint
* Centralized and robust HTTP error handling with httr2
* Contract unification returning empty tibbles on multi-symbol failures
* Vectorized symbol validation and offline construction bypass
* Intraday lookback constraint enforcement and client-side date guards
* Code hygiene, styler formatting, and zero lintr findings

## R CMD check results

Command run:

```
rcmdcheck::rcmdcheck(args = c("--as-cran", "--no-manual"), error_on = "never")
```

Environment: Windows 10 x64, R 4.5.2 (2025-10-31 ucrt).

0 errors | 0 warnings | 1 note

The single NOTE is environmental and not a package defect:

```
* checking for hidden files and directories ... NOTE
  Found the following hidden files and directories:
    .git
  These were most likely included in error. See section 'Package
  structure' in the 'Writing R Extensions' manual.

  CRAN-pack does not know about
    .git
```

This check was run from a git *worktree*, where `.git` is a small pointer
file rather than a directory. `R CMD build` automatically excludes a `.git`
directory (verified with a minimal package: a normal checkout builds without
this NOTE) but does not exclude the worktree `.git` pointer file. Building
and checking from a regular clone yields 0 notes.

## URL checks

`urlchecker::url_check()`: all URLs are correct (37 checked).

## Live smoke tests

Yahoo Finance endpoints were exercised live to close out the residual
verification item for this release:

* `tests/testthat/test-smoke-live.R` (run with `NOT_CRAN=true`):
  15 passed, 0 skipped, 0 failed.
* Minimal live script using the exported functions:
  - 1 month of daily prices for `AAPL` (23 rows) and `INFY.NS` (22 rows) via
    `yf_download_prices()`; 8-column documented schema.
  - One quote via `yf_get_market_stats("AAPL")` (1 row, 7 columns).
  - One annual income statement via `yf_get_financials("AAPL", "income")`
    (4 rows, 23 columns, including `total_revenue`).
  - One `EUR` -> `USD` conversion via `currency_converter()` (24 rows, 7 columns).

## Test Environments

* local Windows 10 x64, R 4.5.2 (the environment used for this pass).
  GitHub Actions CI (macOS/Windows/Ubuntu) is configured but was not executed
  as part of this local pass.
