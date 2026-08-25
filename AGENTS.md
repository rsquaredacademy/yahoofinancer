# AGENTS.md

R package (`yahoofinancer`): R6 + httr2 interface to the Yahoo Finance API. CRAN-published; default branch is `master`.

## Verification workflow

Run in this order after any change:

```r
devtools::document()               # regenerates man/ and NAMESPACE from roxygen
devtools::test()                   # single file: devtools::test(filter = "ticker")
devtools::check(args = "--as-cran") # release gate: target 0 errors / 0 warnings / 0 notes
```

- The test suite is **hermetic**: tests must pass fully offline, never calling the real Yahoo API.
- CI: `.github/workflows/` runs R-CMD-check (macOS, Windows, ubuntu devel/release/oldrel-1), coverage (codecov), and R-hub on every push.

## Testing

Two distinct mocking systems coexist under `tests/testthat/` — check which one a file uses before adding tests:

1. **Custom helper** `with_mock_api()` in `helper-mocks.R` (most tests): injects fake responses via `testthat::with_mocked_bindings` on both `yahoofinancer` and `httr2`. Build mock JSON bodies inline with `mock_response()`.
2. **httptest2 fixtures** (`test-trending.R`, `test-market_summary.R`): recorded JSON under `tests/testthat/api/**`, selected via `httptest2::with_mock_api()` / `with_mock_dir()`.

httptest2 gotcha: the redactor in `setup-httptest2.R` rewrites URLs to short segments (`chart`→`chr`, `quote`→`qt`, `quoteSummary`→`qs`, `trending`→`trnd`, `options`→`opt`, `quote/marketSummary`→`mkt`) so fixture paths stay under 100 bytes — a CRAN tarball-portability requirement. New httptest2 fixtures must match that naming or requests won't resolve to mocks.

Vignette tests (`test-vignettes.R`) only parse vignette code via `knitr::purl`; they don't execute it.

## Architecture

- `YahooFinanceBase` (R/base.R) → `Ticker` (ticker.R) and `Index` (indice.R); `Tickers` (tickers.R) fans out over multiple symbols; `yf_*` functions in functional_api.R are the pipe-friendly API.
- All HTTP goes through `private$api_request()` in base.R: on failure it **warns and returns `invisible(NULL)`** (or empty tibble for multi-ticker paths) rather than erroring. Match this behavior in new endpoints.
- All user-facing returns are tibbles with snake_case columns. `get_history()` schema is fixed at 8 columns: `symbol, date, open, high, low, close, adj_close, volume`; `adj_close` falls back to `close` when the API omits it.
- Deprecated parameter names (e.g., `index` → `symbol`) soft-deprecate with a warning; don't break them.

## Generated files — edit the source

- `README.md` is generated: edit `README.Rmd`, then knit.
- `vignettes/cookbook.Rmd` is generated: edit `vignettes/cookbook.Rmd.orig`, then run `tools/build_vignettes.r`.
- `NAMESPACE` / `man/`: regenerate with `devtools::document()`, never hand-edit.

## Packaging constraints

- New root-level tooling/artifact files (agent logs, coverage output, local libs) must be added to `.Rbuildignore` or they trigger CRAN "top-level files" NOTEs. Existing exclusions cover `specs/`, `.specify/`, `.gemini/`, `lib/`, `audits/`, `coverage.html`.
- `docs/` is the committed pkgdown site (GitHub Pages); rebuild with `pkgdown::build_site()` when reference structure changes (`_pkgdown.yml`).
- `specs/` holds per-feature spec/plan/tasks documents used by the speckit workflow; `GEMINI.md` points at the current plan there.
