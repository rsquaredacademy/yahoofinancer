# yahoofinancer 0.6.2 fix round 1 (job yfx)

Branch `task/yf-fix-062` from origin/master 93d6d07. Findings: Codex audit 2026-11-04 (`cx-yahoofinancer-audit.md`).
Every wrong-result fix has a value-asserting test that was run against the pre-fix code (`git stash` of the R/ change) and failed, then passed after.

| Finding | Test added | Fix | Verified how | Status |
|---|---|---|---|---|
| H1 valuation columns by position | `test-yfx-valuation.R` (reordered MarketCap 200,100 gives 100,200; sparse quarter gives NA,200; absent metric gives typed NA column; union of dates) | `R/ticker.R` `parse_valuation()` keys each metric on its own `asOfDate` (fallback: item timestamp) and joins on the union of dates | 7 expectations failed before, pass after | Fixed |
| H2 dotted symbols in `validate()` | `test-yfx-validate.R` (AAPL + VOD.L; reordered response with BRK.B; several keys in one object; absent symbol gives FALSE); `test-validate.R` index-deprecation mock changed to a real shape (`list("^NSEI" = TRUE)`) | `R/validate.R` reads each result object's exact keys; positional fallback removed | 5 failures/errors before; `Tickers$new(c("AAPL","VOD.L"))` now constructs | Fixed |
| H3 currency adj_close recycling, empty chart | `test-yfx-currency.R` (truncated adj series warns and falls back to close; full series in order; NULL entry gives NA; omitted quote fields give NA; empty chart gives typed empty tibble, no warning) | `R/others.R` `currency_converter()` uses `parse_chart_data()`; typed empty tibble via `empty_currency_tibble()` | 4 failed before | Fixed |
| H4 symbol field leaves another ticker's cache | `test-yfx-symbol-cache.R` (assigning `t$symbol <- "MSFT"` gives 200 not 100; one request per symbol; `set_symbol()` still refreshes) | `R/ticker.R` cache keyed by symbol (`cached_meta_symbol`); class docs state the cache has no time expiry | 1 failed before | Fixed |
| H5 suite not hermetic | `setup-hermetic.R` (blocks httr2 `req_perform1`, below the mock hook, and forces `has_internet()` TRUE), `test-yfx-hermetic.R`; test constructors use `validate = FALSE`; `test-smoke-live.R` needs `YF_LIVE_TESTS=true` | tests only | Full suite green under the blocker; a test asserts an unmocked request is blocked and counted | Fixed |
| H6 version 0.6.1 already on CRAN | n/a | `DESCRIPTION` Version 0.6.2, NEWS | check: no version warning | Fixed |
| M1 market stats NA row | `test-yfx-failure-schemas.R` (failed metadata: zero rows, one warning, exactly 2 requests: validate + metadata; partial row typed) | `R/functional_api.R` `yf_get_market_stats()` checks metadata once (`ticker_meta_available()`), warns per symbol, typed columns | failed before | Fixed |
| M2 untyped empty results | same file (names and types for `yf_download_prices`, `yf_get_index_quotes`, `yf_get_market_stats`, `yf_get_financials`, `Tickers$get_history`; `dplyr::select(symbol, date)` works on a failed call) | `R/utils.R` `empty_*_tibble()` helpers used on every full-failure path | failed before | Fixed |
| M3 maintainer email | n/a | `DESCRIPTION` | check shows new maintainer | Fixed |
| M4 testthat floor | n/a | `testthat (>= 3.2.1)` | DESCRIPTION | Fixed |
| M5 consent banner timezones | `tools/test-site-kit.js` (`node tools/test-site-kit.js`; fails before) | `pkgdown/assets/site-kit/rsa-analytics.js` adds Asia/Nicosia, Asia/Famagusta, Atlantic/Azores; copied byte-identically to `docs/site-kit/` | node test | Fixed (full site rebuild deferred) |
| L1 unasserted warning | `test-parse_chart_data.R` now `expect_warning(..., "Adjusted close length")` | test only | no warnings in the suite | Fixed |
| L2 cran-comments | n/a | Rewritten for 0.6.2 (actual environment, check result, hermetic and opt-in live wording, `\dontrun`) | read | Fixed |
| L3 unused direct jsonlite import | `test-yfx2-parser.R` in round 2 parses a recorded body through the real parser and asserts price 155.81 | Round 1 incorrectly moved jsonlite to Suggests: httr2 only Suggests it, but `resp_body_json()` requires it at runtime. RX1 restores Imports; the unused NAMESPACE import stays removed | Round 1's dependency check was insufficient; round 2 verifies the required dependency declaration and real parsing | Corrected by RX1 (yfx2) |
| L4 odd response shapes | `test-yfx-hardening.R` (JSON `true`, `1`, `"x"` give warning and NULL; numeric `reportedValue` = 100; `raw` and `raw = NULL` still work) | `R/api_request.R` shape guard; `R/ticker.R` numeric check before `$raw` | 2 failed before | Fixed |

## Deferred

* L5 (curly quotes in `<link rel="icon" type=...>` in generated `docs/` pages): the quotes come from pkgdown's favicon generation, not from any file in `pkgdown/`. A fix needs a full site rebuild (`tools/build_site.R`), which rewrites most of `docs/`; not done, and no hand edits of generated pages.
* L6 (`docs/GEMINI.html` links to an absent `specs/002-v061-hotfixes/plan.html`): site-generation exclusion; same rebuild.
* The full site rebuild (also needed to publish the M5 JS through pkgdown). `docs/site-kit/rsa-analytics.js` was updated by copying the source, which is what the build does.
* A CI job that sets `YF_LIVE_TESTS=true` for the opt-in live test: no workflow was changed.

## Checks

* `devtools::test()` (NOT_CRAN=true): 417 passed, 0 failed, 0 errors, 0 warnings; `test-smoke-live.R` skips (opt-in).
* Clean `git archive` of commit 8703ef6 built with `R CMD build`, then `R CMD check --as-cran --no-manual yahoofinancer_0.6.2.tar.gz`: 0 errors, 0 warnings, 1 note. Installed tests `[ FAIL 0 | WARN 0 | SKIP 1 | PASS 417 ]`.
* The one NOTE is CRAN incoming feasibility: "New maintainer ... Old maintainer(s): hebbali.aravind@gmail.com". Intended (M3).
* Commits after the check (this report, cran-comments) touch only files excluded by `.Rbuildignore` (`docs-dev`, `cran-comments.md`), so the built tarball is identical.
* Not run: other platforms, win-builder, R-hub. The package has no vdiffr snapshots.

## Commands run that changed something

`devtools::document()` (regenerated `man/` and NAMESPACE; roxygen version drift reformatted a few unrelated Rd files, harmless), scripted edits, `cp pkgdown/assets/site-kit/rsa-analytics.js docs/site-kit/`, local commits. No push, no gh, no branch switches. Scratch (`scratch-check/`, `run-tests.R`) lived inside the worktree and is not committed.

## Needs Aravind

* New maintainer address: CRAN will email the old address (hebbali.aravind@gmail.com) to confirm; that mailbox must be reachable at submission.
* Decide whether to schedule the full pkgdown rebuild (L5, L6, publish M5) before or after CRAN.
