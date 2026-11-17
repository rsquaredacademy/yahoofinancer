# yahoofinancer 0.6.2 fix round 2 (pkg-yfx2)

Worktree: `F:/R/Packages/_worktrees/yf-fix-062`, branch `task/yf-fix-062`.
Starting HEAD: `f4284a316a5e02c3575f1af3f0d5378d78bd3111`.
Read `F:/pm/notes/2026-11-01-pkg-audits/common-pkgfix.md`, root `AGENTS.md`,
and `docs-dev/yfxx-reaudit.md` before changes. RX1, RX2, RX3, RX4, and RX7
are fixed. RX5/RX6 remain open website defects, described in full below.
No exported API was added or removed. The existing jsonlite runtime dependency
was restored; no additional dependency was introduced.

| Finding | Test added | Fix (file:line) | Before / after evidence and verification | Status |
| --- | --- | --- | --- | --- |
| RX1: missing runtime JSON dependency and incomplete condition diagnostics | `test-yfx2-parser.R`: Imports declaration; unchanged recorded chart body through real `httr2::resp_body_json()`; metadata price 155.81 and symbol AAPL; formatted condition with empty `$message` | `DESCRIPTION:16`; `R/api_request.R:39`, `R/api_request.R:51`, `R/api_request.R:55`; release claims in NEWS, cran-comments, and the old report L3 row corrected | Before: declaration assertion fails; formatted parser condition loses its useful text. After: jsonlite is in Imports, both handlers use `conditionMessage(e)`, and the parser test passes. Installed tarball also works with only the declared recursive Depends/Imports/LinkingTo closure plus base/recommended packages: jsonlite TRUE, testthat FALSE, two history rows, eight columns, one fake transport call, zero warnings. No NAMESPACE import added. | Fixed |
| RX2: lowercase symbols rejected by canonical response keys | `test-yfx2-validate.R`: lowercase aapl/vod.l, mixed case, reordered canonical keys, BRK.B, missing VOD-L, duplicates and NA; constructors; recorded AAPL response and README constructor replay | `R/validate.R:19`, `R/validate.R:91`, `R/validate.R:102`; generated `man/validate.Rd` | Before: aapl is FALSE and lowercase constructors error. After: caller vector `aapl,vod.l,mSfT,BrK.b,VoD.L,VOD-L,aapl,NA` returns `TRUE,TRUE,FALSE,TRUE,TRUE,FALSE,TRUE,FALSE` with original names/order; character result is `aapl,vod.l,BrK.b,VoD.L,aapl`. The unchanged recorded uppercase AAPL response validates lowercase aapl. The exact `aapl <- Ticker$new("aapl")` line extracted from README.md constructs an object whose symbol is aapl. Matching canonicalizes case only, preserves punctuation, and never uses response position. | Fixed |
| RX3: live opt-in still blocked by setup | `test-yfx2-live-selection.R`: capture setup bindings under default and opt-in environments; existing deliberate-blocker test skips in live mode; separate fake-transport replay of actual smoke file | `tests/testthat/setup-hermetic.R:18`; `tests/testthat/test-yfx-hermetic.R:4` | Before: opt-in setup installs two offline bindings; regression expects zero and fails. After: default installs both blocker and forced connectivity; exact `YF_LIVE_TESTS=true` installs neither. Actual opt-in smoke file: 15 passes, eight fake req_perform1 calls, zero curl calls. Default full suite: 493 passes and zero independent curl calls. No live Yahoo request was sent. | Fixed |
| RX4: arrays accepted as objects; malformed envelope can throw; missing error descriptions | `test-yfx2-parser.R`: real scalar/array bodies; malformed chart/result/error containers at HTTP 200 and 404; missing/NULL diagnostics; missing/NULL statement values and dates; real insights object result | `R/api_request.R:66`, `R/api_request.R:75`, `R/api_request.R:95`; `tests/testthat/helper-mocks.R:6` | Before: [1] and [] are accepted without warning; HTTP 404 chart=1 throws an atomic `$` error; a non-text error description becomes misleading text. After: non-object bodies and malformed supported envelopes warn and return NULL; missing/NULL/non-text descriptions give `Yahoo Finance API failed [404]: Unknown Error`; valid description remains `Missing symbol`. Supported finance insights object results still return MSFT. Existing statement semantics are preserved and now tested with real JSON: revenue `100,NA,NA,NA`, dates 2021–2024, missing period types NA, missing/NULL dates skipped. | Fixed |
| RX7: five stale generated help files | `devtools::document()` regeneration, followed by full tests and clean archive check | `man/Tickers.Rd:161`, `man/yf_download_prices.Rd:41`, `man/yf_get_market_stats.Rd:18`, `man/yf_get_financials.Rd:25`, `man/yf_get_index_quotes.Rd:18` | Before: generic empty-tibble wording; financials omits its failure-schema columns. After: generated zero-row/fixed-schema wording matches the existing roxygen source. Repeated documentation generation produces no further changes. NAMESPACE is unchanged. | Fixed |

## Files changed

* `R/validate.R` and `man/validate.Rd`: case-insensitive symbol identity and the
  explicit spelling/order contract.
* `DESCRIPTION` and `R/api_request.R`: required parser dependency, complete
  condition messages, JSON object/envelope checks, safe error-description lookup.
  The finance insights endpoint can return an object rather than an array of
  objects, and remains supported.
* `tests/testthat/helper-yfx2.R`, `test-yfx2-parser.R`, and
  `test-yfx2-validate.R`: transport-only mocks with actual JSON parsing and value
  assertions. The README replay reads the generated README.md; its constructor
  is unchanged from the `ticker` chunk in README.Rmd. The two README-specific
  assertions run in the source worktree, where that file is present.
* `tests/testthat/helper-mocks.R`: default empty JSON object now has
  `names = character()`, matching jsonlite's object representation; an unnamed
  empty list represents an array. Existing test error expectations remain valid.
* `tests/testthat/setup-hermetic.R`, `test-yfx-hermetic.R`, and
  `test-yfx2-live-selection.R`: explicit live selection without weakening
  default offline runs.
* `man/Tickers.Rd`, `man/yf_download_prices.Rd`, `man/yf_get_market_stats.Rd`,
  `man/yf_get_financials.Rd`, `man/yf_get_index_quotes.Rd`: regenerated from
  roxygen, never hand-edited.
* `NEWS.md`, `cran-comments.md`, `docs-dev/yfx-report.md`: corrected release
  claims, including the unsafe round-1 L3 dependency conclusion.
* `.Rbuildignore`: excludes the new `.yfx2-tmp` scratch directory.
* `docs-dev/yfx2-report.md`: this report.

## Test and build evidence

Regression tests were added and run before the R/metadata/setup fixes. The
pre-fix log `.yfx2-tmp/before-tests.log` contains failures for dependency
declaration, condition text, arrays/envelope handling, lowercase validation,
and opt-in setup selection. Existing missing/NULL statement-value behavior was
already correct and is protected by additional real-JSON assertions.

The first full run also checked compatibility with object-valued finance
insights and old empty-object mocks; these were accommodated before the green
full-suite run. The first archive check found an extra unused-Imports NOTE
after restoring jsonlite. Explicitly loading that required namespace before
calling httr2's parser removes the NOTE without a NAMESPACE import.

Final code verified at `117bd2d`:

```text
devtools::document(): no remaining generated-file changes
NOT_CRAN=true; YF_LIVE_TESTS unset; R_CHECK_INTERNET_AVAILABILITY=FALSE
devtools::test(): 493 passed, 0 failed, 0 errors, 0 warnings
Live smoke file skipped (one opt-in skip)
Independent curl transport calls: 0
```

The independent wrapper replaces curl memory/disk/stream and multi-add
transport with a counting blocker and reports real connectivity FALSE. Suite
setup still forces package connectivity TRUE so mocked endpoints execute.
The existing hermetic test confirms that an escaped request is blocked locally.
Both mocking systems execute successfully.

Additional isolated probes:

```text
Actual smoke-live file with YF_LIVE_TESTS=true and fake lower transport:
  15 passed; 0 failures/errors/warnings/skips
  Fake req_perform1 calls: 8; independent curl calls: 0
Required-dependencies-only installed tarball:
  jsonlite available: TRUE; testthat available: FALSE
  History rows: 2; columns: 8
  First close: 157.96; first adjusted close: 157.96 (display rounding)
  Transport calls: 1; warnings: 0
Recorded-body shape compatibility probe:
  52 valid UTF-8 recorded bodies parsed without rejection
  1 invalid UTF-8 legacy recording correctly warned and returned NULL
  Fake transport calls: 53
```

The private-library probe restricts `.libPaths()` to the copied dependency/base
library and mocks only connectivity and transport, leaving JSON and chart
parsing real. It asserts every returned close against the recorded raw values.
No system library or other worktree was modified.

Clean `git archive` build/check of `117bd2d`:

```text
R CMD build ../verified-head: success, including vignettes
R CMD check --as-cran --no-manual yahoofinancer_0.6.2.tar.gz
0 errors | 0 warnings | 1 NOTE
Installed tests: [ FAIL 0 | WARN 0 | SKIP 1 | PASS 491 ]
Examples: OK
Vignettes and rebuilding vignette outputs: OK
Dependencies in R code: OK
```

The two-assertion source/installed difference is the README replay: README.md
is not present beside the installed tests. Lowercase constructor and recorded
JSON assertions still run in the installed suite.

The complete remaining NOTE is intentional:

```text
* checking CRAN incoming feasibility ... NOTE
Maintainer: 'Aravind Hebbali <aravindhebbali@rsquaredacademy.com>'

New maintainer:
  Aravind Hebbali <aravindhebbali@rsquaredacademy.com>
Old maintainer(s):
  Aravind Hebbali <hebbali.aravind@gmail.com>
```

Verification logs are retained under `.yfx2-tmp/`: `document.log`,
`offline-tests.log`, `live-selection.log`, `required-lib-prepare.log`,
`required-lib-install.log`, `required-lib-probe.log`, `recordings-replay.log`,
and `verified-check.log`. The post-report-commit release gate uses another
clean archive named `final-head`, with output in `final-check.log` and
`final-head-check/yahoofinancer.Rcheck/00check.log`. Only this excluded report
is added after the verified code commit; package source/build inputs are the
same for the post-commit repeat.

## Commands run

PowerShell uses semicolons, and every heavy R/build/check invocation is wrapped
with `bash ~/.claude/bin/heavy-slot.sh pkg-yfx2`. Scratch scripts, source
archives, the private library, build products, and logs are in `.yfx2-tmp/`.
Later verification also places R temporary directories there. LANG/LC_ALL are
C for the release checks; NOT_CRAN and YF_LIVE_TESTS are unset for R CMD check.

```text
bash ~/.claude/bin/heavy-slot.sh pkg-yfx2 Rscript -e '... devtools::test(filter="yfx2", reporter="summary")'
bash ~/.claude/bin/heavy-slot.sh pkg-yfx2 Rscript -e 'devtools::document()'
bash ~/.claude/bin/heavy-slot.sh pkg-yfx2 Rscript .yfx2-tmp/run-offline.R
bash ~/.claude/bin/heavy-slot.sh pkg-yfx2 Rscript .yfx2-tmp/run-live-selection.R
bash ~/.claude/bin/heavy-slot.sh pkg-yfx2 Rscript .yfx2-tmp/prepare-required-lib.R
bash ~/.claude/bin/heavy-slot.sh pkg-yfx2 R CMD INSTALL --library=.yfx2-tmp/required-lib .yfx2-tmp/verified-head-check/yahoofinancer_0.6.2.tar.gz
bash ~/.claude/bin/heavy-slot.sh pkg-yfx2 Rscript .yfx2-tmp/probe-required-lib.R
bash ~/.claude/bin/heavy-slot.sh pkg-yfx2 Rscript .yfx2-tmp/replay-recordings.R
git archive --format=tar --output=.yfx2-tmp/verified-head.tar HEAD
tar -xf .yfx2-tmp/verified-head.tar -C .yfx2-tmp/verified-head
bash ~/.claude/bin/heavy-slot.sh pkg-yfx2 bash .yfx2-tmp/build-check.sh verified-head
  R CMD build ../verified-head
  R CMD check --as-cran --no-manual yahoofinancer_0.6.2.tar.gz
git archive --format=tar --output=.yfx2-tmp/final-head.tar HEAD
tar -xf .yfx2-tmp/final-head.tar -C .yfx2-tmp/final-head
bash ~/.claude/bin/heavy-slot.sh pkg-yfx2 bash .yfx2-tmp/build-check.sh final-head
  R CMD build ../final-head
  R CMD check --as-cran --no-manual yahoofinancer_0.6.2.tar.gz
git diff --check
```

Files were changed with patches and roxygen regeneration. Local commits:

* `a08fdf6`: RX2 case-insensitive canonical keys and tests.
* `197ed2b`: RX1/RX4 dependency, real parser tests, and envelope guards.
* `6aff730`: RX3 explicit live setup selection.
* `28a3a72`: RX7 generated return schemas.
* `aa9f522`: corrected release claims and scratch exclusion.
* `117bd2d`: explicit required JSON namespace load to remove the check NOTE.
* The report commit records this evidence; every round-2 commit ends `(yfx2)`.

## Follow-ups / deferred work

* RX5 / original L5: 34 generated HTML pages retain malformed curly quotes in
  the SVG favicon MIME attribute. Fix the favicon generation template/path,
  rebuild the website with `source("tools/build_site.R")`, and verify generated
  favicon declarations across all pages use a valid `image/svg+xml` attribute.
  Do not hand-edit generated docs or call plain `pkgdown::build_site()`.
  No source/configuration fix or site rebuild is included in this round.
* RX6 / original L6: `docs/GEMINI.html` still links to the missing
  `specs/002-v061-hotfixes/plan.html`. Exclude that internal developer page from
  site generation or replace its link with an appropriate public destination,
  rebuild with `source("tools/build_site.R")`, and verify the resolved target
  exists. This remains open; a rebuild alone is not a source fix.
* Legacy recording `tests/testthat/api/qs/hasgx-e1ee14.json` contains invalid
  UTF-8. It was left unchanged; real UTF-8 JSON parsing correctly warns/returns
  NULL for that recording. Repairing/re-recording unused legacy quoteSummary
  fixtures is outside the requested fixes.
* No live Yahoo compatibility run or live CI job was requested or performed.
  The opt-in route was verified with fake transport only. No other OS/R-version
  matrix, dependency-minimum matrix, PDF manual, win-builder, R-hub, or reverse
  dependency check was run.
* CRAN submission still requires acknowledgement of the intentional maintainer
  address change through the old mailbox if requested.

`docs-dev/yfxx-reaudit.md` and `.yfxx-tmp/` remain untracked and untouched.
New scratch/evidence remains untracked in `.yfx2-tmp/`, excluded from builds.
No website files were changed. No push, GitHub/gh operation, branch switch,
other-worktree modification, or external message was performed.
