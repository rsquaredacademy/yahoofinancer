# yahoofinancer — Package Review & Adoption Roadmap

**Status:** Canonical roadmap. Supersedes `audits/yahoofinancer-review.pdf` (Aug 2026), whose
findings are dispositioned in the Appendix.
**Snapshot:** yahoofinancer 0.5.0.9000 (development) · CRAN 0.5.0 published May 2026 · Review date: August 2026
**Revision:** 2026-08-24 — second-round review (`roadmap_feedback.md`) incorporated: tracker-reconciliation actions (§2.4), v0.6.x rescoped as the v0.6.1 milestone with the crumb dependency made explicit, release ladder revised (v0.8.0 data acquisition → v0.9.0 computed analytics → v0.10.0 screening engine), backend blueprint extracted to `backend_blueprint.md`, risk/metric adjustments.
**North star:** A screener.in-style screening *backend* built entirely on Yahoo Finance data, powered by this package as its data layer.

---

## 1. Executive summary

yahoofinancer is the most ambitious Yahoo Finance client in the R ecosystem and the only one
attempting anything beyond price history. The v0.6.0 cycle delivered exactly what the previous
review prescribed for Phase 1–2: a migrated httr2 network engine with retry/backoff/timeout,
a vectorized functional (`yf_*`) layer, tidy tibble contracts, hermetic offline tests, and a
5-platform CI matrix. That work is real and it shows.

Three problems now stand between the package and broad adoption:

1. **A shipped-but-broken flagship feature.** `yf_get_financials()` — advertised in the README —
   calls `get_income_statement()` / `get_balance_sheet()` / `get_cash_flow()`, methods that were
   removed from `Ticker` during the August 2023 emergency refactor (commit `52bc37e`). Tests mock
   those methods, so CI is green while production silently returns empty tibbles. GitHub issue #2
   is a user hitting this exact hole. Everything downstream depends on fixing it.
2. **An unfinished reliability story.** No caching, sequential multi-symbol fetches, duplicated
   HTTP/error boilerplate outside the base class, silent failure swallowing, and no defense against
   the aggressive rate-limiting Yahoo introduced in 2025. This is precisely the v0.7.0 backlog.
3. **No screener story yet.** Python's `yfinance` added a server-side screener client
   (`EquityQuery` DSL + predefined screens) that filters Yahoo's entire universe without downloading
   a single ticker. No R package offers anything comparable. This is the single largest unclaimed
   opportunity in the R finance ecosystem — and the natural core of a screener.in-style backend.

The strategy below follows four pillars, mapped onto a release ladder anchored on the existing
GitHub milestones (v0.7.0 and v0.8.0 open; v0.8.0's scope narrowed in the 2026-08-24 revision,
with analytics and screening pushed to proposed v0.9.0/v0.10.0 — see §2.4 for the tracker
reconciliation):

> **Finish foundations → reliability at scale → own fundamentals & analytics → build the screening
> engine → become the data backbone for a screener.in-style backend.**

---

## 2. State of the package (August 2026)

### 2.1 What exists and works

| Area | Detail |
|------|--------|
| Architecture | `YahooFinanceBase` (R/base.R) → `Ticker` (ticker.R), `Index` (indice.R); `Tickers` fan-out class (tickers.R); pipe-friendly `yf_*` layer (functional_api.R) |
| Network engine | Single `private$api_request()` in base.R:123 — httr2, `req_retry(max_tries=4)` with exponential backoff, 15 s timeout, standardized warning + `invisible(NULL)` on failure |
| Functional layer | `yf_download_prices()`, `yf_get_market_stats()`, `yf_get_index_quotes()`, `yf_get_financials()` |
| Market utilities | `get_market_summary()` (tidy or raw), `get_trending()`, `get_currencies()`, `currency_converter()`, `validate()` (vectorized, `return_logical`) |
| Output contract | Tibbles everywhere; `get_history()` schema frozen at 8 columns (`symbol, date, open, high, low, close, adj_close, volume`); `adj_close` falls back to `close` |
| Testing | Hermetic suite (235 tests, forced offline), dual mocking systems (binding mocks + httptest2 fixtures with URL redaction), vignette smoke tests |
| CI/CD | R-CMD-check on macOS/Windows/ubuntu (devel, release, oldrel-1), codecov, R-hub, committed pkgdown site |

GitHub milestone status: **v0.6.0 "Functional Layer & httr2 Engine"** — all issues closed (the
milestone itself is still marked open on GitHub; see §2.4). Open milestones: **v0.7.0**
(reliability/scale) and **v0.8.0**, whose scope this revision narrows to fundamentals data
acquisition — analytics move to proposed v0.9.0, screening to proposed v0.10.0.

### 2.2 Defect register (verified against source)

| ID | Severity | Finding | Evidence |
|----|----------|---------|----------|
| F-01 | **Critical** | `yf_get_financials()` calls three methods that do not exist on `Ticker`; every call fails internally and returns an empty tibble. Regression: the methods existed pre-Aug-2023 and were dropped in commit `52bc37e` when Yahoo broke quoteSummary. Tests mask it by mocking `Ticker` with those methods. README advertises the feature. | R/functional_api.R:176-178; tests/testthat/test-functional_api.R:115-151; issue #2 |
| E-01 | High | HTTP + error-reporting boilerplate duplicated 4× outside the base class (`get_currencies`, `get_market_summary`, `get_trending`, `currency_converter`, plus `validate`). The copies print via `cat()` to stdout (untestable), contain the user-facing typo `"Mesage:"`, and read `parsed$quoteSummary$error` even for chart/currencies endpoints whose errors live under `$chart$error`. | R/others.R; R/validate.R:56-98; correct pattern at R/base.R:158-168 |
| E-02 | High | Silent error swallowing in `Tickers$aggregate_data()`: `tryCatch(..., error = function(e) NULL)` emits nothing. Network outage and a typo'd method are indistinguishable from "no data". | R/tickers.R:111 |
| E-03 | High | Request amplification. Every active binding triggers a fresh chart-API call through `meta_info()`; reading 5 properties on a 10-symbol `Tickers` object costs 50 sequential requests. `validate()` sends one request per symbol although the endpoint accepts comma-separated lists. `Ticker$new()` performs a network round-trip per symbol before any data is fetched. | R/ticker.R:154-160; R/validate.R:56-90; R/base.R:26-32 |
| E-04 | Medium | Date-contract gaps. `get_history(end=...)` without `start` silently ignores `end` (falls back to relative range); `currency_converter()` parses dates with raw `ymd()` without the `is.na()` guard, so invalid input becomes `NA` timestamps sent to the API; documented intraday lookback limits (1m ≤ 7 d, 5m/15m/30m ≤ 60 d, 1h ≤ 730 d) are not enforced client-side. | R/base.R:83-108; R/others.R:346-351 |
| E-05 | Medium | Failure contract inconsistency across the surface: `invisible(NULL)` vs empty `data.frame()` vs empty tibble vs raw `list()` depending on entry point. | R/others.R; R/tickers.R:117 |
| E-06 | Low | Hygiene debt: ~200 style lints (no `.lintr` config); `%>%` vs `|>` policy conflict while `DESCRIPTION` declares R ≥ 3.4; both `httptest` and `httptest2` in Suggests; bare User-Agent `"yahoofinancer"` (no version); deprecated pkgdown keys (`ganalytics`, `navbar type: inverse`); built `docs/` committed to master. | DESCRIPTION; _pkgdown.yml; audit_codebase.md |

### 2.3 Documentation-vs-reality drift

The superseded review (PDF) and its recipes reference roughly a dozen `Ticker` members that have
never existed in the current codebase: `key_stats`, `summary_detail`, `financial_data`,
`esg_scores`, `earnings`, `earnings_history`, `upgrade_downgrade_history`, `company_officers`,
`insider_transactions`, `institution_ownership`, `income_statement(frequency=)`, SEC filings,
options chains. These are `yfinance`/`yahooquery` surfaces. They define the *target* API for
v0.8.0 rather than describing today's package. The shipped cookbook and guides are clean;
only the PDF recipes and the README's financial-statements claim (see F-01) over-promise.

### 2.4 GitHub ↔ roadmap reconciliation (action list, 2026-08-24)

The second-round review found the tracker and this document drifting — several items exist in
only one place. These actions reconcile them and precede any code work:

| Action | Detail |
|--------|--------|
| Close the v0.6.0 milestone | All 7 issues closed, but the milestone itself is still open on GitHub |
| Create a v0.6.1 milestone | File one issue per §5.1 row — the most critical track currently has no issue trail at all |
| Move #31 (`yf_status`) and #32 (suffix helper) into v0.7.0 | Both exist as issues but sit outside the milestone, unlike what this roadmap assumes |
| File the cookie/crumb groundwork issue | Currently a dash-row; it is the keystone for v0.8.0 WS-2 and possibly the F-01 fix itself |
| Move #38 (`yf_screen`) out of v0.8.0 | GitHub places it in v0.8.0; the roadmap treats server-side screening as its own milestone → v0.10.0 (§5.5). Resolve in favor of v0.10.0 |
| Stub the v0.9.0 and v0.10.0 milestones | The analytics split and screener engine need trackable homes once this ladder is agreed |

---

## 3. Competitive landscape

### 3.1 R packages

| Axis | yahoofinancer | yfR | quantmod | tidyquant |
|------|--------------|-----|----------|-----------|
| API style | Functional (`yf_*`) + R6 power tier | Purely functional | Functions (`getSymbols`) | tidyverse wrappers |
| Output | tibbles, snake_case | tibbles (long) | xts | tibbles |
| Caching | None (v0.7.0 planned) | Session-persistent smart cache (rds) | None | None |
| Parallel fetch | Planned v0.7.0 (furrr) | Yes (furrr/future) | No | No |
| Price history | Yes (+ intraday intervals) | Yes (daily/w/m/y aggregation) | Yes | Yes |
| Dividends/splits | Via adjusted close only | Dividends yes | Via Yahoo source | Via quantmod |
| Fundamentals | Valuation-measure timeseries only today; statements broken (F-01) | None | Minimal | Minimal |
| Quotes/52w/currency | Yes | Live prices only | No | Limited |
| Screener | Planned v0.10.0 | No | No | No |
| Peer review | No | rOpenSci (badge on CRAN page) | De-facto standard since ~2009 | Widely used |
| CRAN traction | ~10.5 K downloads/yr (~29/day, rank ≈ #4,057); 20 GitHub stars | Substantially larger; rOpenSci halo | Very large (installed with the quant stack) | Large |

**Reading:** yfR wins the "just give me prices" crowd with cache + parallelism + collections
(index constituents such as SP500/IBOV/FTSE scraped from reference sources). quantmod wins by
decade-long incumbency inside the xts/TTR/quantmod stack. Neither offers fundamentals, quotes,
currency, or screening. yahoofinancer is the only R package positioned for fundamental research —
but today it cannot actually deliver statements (F-01), which is why the fix leads everything.

### 3.2 Python benchmarks

- **yfinance** (de facto standard): full `Ticker` surface (info, financials, holders, earnings
  dates, options, news), `Search`, `Sector`/`Industry`, WebSocket streaming — and since 2024 a
  **server-side screener**: `EquityQuery`/`FundQuery`/`ETFQuery` compose operators
  (`eq, gt, lt, gte, lte, btwn, is-in, and, or`) over registered fields (price, trading,
  income-statement, balance-sheet, short-interest categories) plus ~20 predefined screens
  (day gainers, undervalued growth, most actives…), paginated at 250 rows. It also survived
  Yahoo's 2025 hardening: rotating cookie/crumb authentication, TLS-fingerprint-based blocking,
  and aggressive 429 responses — resolved via browser-impersonation sessions and careful cookie reuse.
- **yahooquery**: broadest endpoint coverage in Python (fundamentals timeseries, screener, login);
  the original inspiration for this package's OOP design.

**Two lessons to import:**

1. **The server-side screener is the killer feature** for the screener.in goal: whole-universe
   filtering executed on Yahoo's infrastructure, no need to enumerate thousands of tickers.
2. **Robustness is now an arms race.** Plain HTTP clients get blocked. The package must plan for
   cookie/crumb session handling and disciplined rate budgeting (v0.7.0 groundwork, §5.2).

### 3.3 Positioning statement

> *yahoofinancer is the tidy fundamentals-and-screening interface to Yahoo Finance for R.*
> Prices for everyone (functional tier, cached, parallel); fundamentals, quotes and screens for
> analysts (same functions, more arguments); R6 remains available for power users.

This wedge — fundamentals + screening in tidy R — is owned by nobody else in the ecosystem.

---

## 4. Guiding principles

1. **Zero breaking changes.** Deprecated names soft-deprecate with warnings; schemas only ever grow.
2. **One failure contract.** Warn once, name the failed symbol, return an empty tibble with the
   documented schema. Never lie with silence (fixes E-02/E-05).
3. **Tidy in, tidy out.** New endpoints land as snake_case tibbles with documented column schemas
   and explicit "returns empty when" notes.
4. **Offline-testable by construction.** Every new endpoint ships with httptest2 fixtures under the
   existing URL-redaction scheme; the live canary (v0.7.0) is the only place reality touches CI.
   Mocks are derived from recorded real responses, never hand-crafted to satisfy expectations —
   the test suite must not invent API surfaces (the F-01 lesson).
5. **Respect the host.** Versioned User-Agent, conservative rate budgets, caching to avoid waste —
   both because Yahoo will block abusers and because it is the right thing to do against a free,
   unofficial API.
6. **Honest docs.** Nothing appears in README/vignettes until it works against the real API.

---

## 5. Roadmap by milestone (ladder revised 2026-08-24: v0.8.0 split into acquisition + analytics; screener engine → v0.10.0)

Release ladder: **v0.6.1 hotfixes → v0.7.0 reliability & scale → v0.8.0 fundamentals data
acquisition → v0.9.0 computed analytics → v0.10.0 screening engine → v1.0 stabilization.**
Each milestone exits with a CRAN release; v0.6.1 must ship to CRAN before v0.7.0 development opens.

### 5.1 v0.6.1 — finish the functional layer *(immediate hotfix track; completes the closed v0.6.0 promise)*

Goal: make every currently exported function truthful. Hotfix track, not new scope. Rows are
ordered deliberately: fixes before audits, lint last (linting before refactors creates churn),
and the documentation-drift guard deferred to v0.7.0 — it prevents future regressions but fixes
no current bug.

> **Tracker:** none of these have GitHub issues yet (§2.4). Creating the v0.6.1 milestone and
> filing one issue per row is itself a do-now action.

| # | Item | Detail | Acceptance criteria |
|---|------|--------|---------------------|
| 1 | Fix F-01 | Implement `Ticker$get_income_statement()`, `$get_balance_sheet()`, `$get_cash_flow()` on the `fundamentals-timeseries` endpoint (annual + quarterly), returning the documented tibble shape; wire into `yf_get_financials()`. Full module breadth stays in v0.8.0 — this is the minimum that makes the shipped README true. **Dependency, stated plainly:** `fundamentals-timeseries` is crumb-gated as of Yahoo's 2025 hardening, and its columnar timeseries layout differs fundamentally from the old `quoteSummary` modules — budget for type-code discovery plus an explicit pivot to row-per-period tibbles. If live calls fail without crumb auth, pull the minimal cookie/crumb spike forward from v0.7.0 rather than descoping back to mocks. | Real-API smoke test passes for AAPL/GOOG/RELIANCE.NS; `yf_get_financials(c("AAPL","MSFT"))` returns non-empty frames; tests consume recorded live traffic only |
| 2 | Unify HTTP/error paths (E-01) | Route `get_currencies`, `get_market_summary`, `get_trending`, `currency_converter`, `validate` through the base-class request helper (extracted to an internal module-level function); delete the four `cat()` copies and the `"Mesage:"` typo. Multi-file refactor (5 files) — schedule as one commit series. | One request helper in `R/`; grep finds zero `cat("Yahoo Finance API request failed"` occurrences |
| 3 | Failure contract (E-02/E-05) | `aggregate_data()` warns with the failed symbol; document and enforce "empty tibble with expected schema" everywhere. Sequenced after row 2 so there is one code path to enforce it on. | Documented contract in every roxygen `@return`; new tests assert warnings |
| 4 | Batch validation (E-03 partial) | `validate()` issues a single comma-separated request; cache meta per `Ticker` instance (invalidate on `set_symbol`). Quick win. | N symbols = 1 validation request; repeated property reads = ≤ 1 meta request per object |
| 5 | Date hygiene (E-04) | Error on invalid `start`/`end`; warn-or-error on orphan `end`; guard `ymd()` in `currency_converter()`; enforce intraday lookback limits client-side with informative messages. Quick win. | Unit tests for each rejection path |
| 6 | Mock-surface audit | Sweep `helper-mocks.R` and all httptest2 fixtures for simulated methods/endpoints that do not exist on the real surface (the pattern that masked F-01). Written policy: mocks derive from captured live traffic, never from what a test wishes existed. Extended per review: **one mocking system going forward** — httptest2 for every new endpoint; legacy binding-mock helpers migrate opportunistically and are never duplicated further. | Zero mocks referencing non-existent surfaces; mocking policy documented in CONTRIBUTING.md |
| 7 | Lint & floor pass (E-06) — **runs last**, after rows 1–6 land | Commit `.lintr`, run `styler::style_pkg()`, add lint job to CI; resolve `%>%`/`\|>` policy by keeping `%>%` and disabling the consistency linter; **raise `Depends: R (>= 3.4)` to `R (>= 4.1)`** (httr2 already requires ≥ 4.0 — the declared floor is latently false); drop unused `httptest` Suggest; User-Agent becomes `yahoofinancer/<version>`; fix deprecated `_pkgdown.yml` keys; unmilestone stale bugs (#17 closeable — adj_close standardized; triage #5). | `lintr::lint_package()` clean; DESCRIPTION declares R ≥ 4.1; CI green incl. lint job |
| 8 | Release hygiene | Populate `NEWS.md` — the landed v0.6.0 work (httr2 migration, functional API, `Tickers`, hermetic suite) is currently absent from the development-version header — refresh `cran-comments.md`, submit v0.6.1 to CRAN. **v0.7.0 development does not open until this ships.** | v0.6.1 accepted on CRAN; NEWS documents all v0.6.x changes |

Effort: honestly sized at **3–4 weeks of focused work**, not a weekend sprint — rows 2–3 are
multi-file refactors and row 1 carries real API-discovery risk. Risk: low beyond F-01's crumb
unknown. This phase unlocks trust for everything else.

### 5.2 v0.7.0 — reliability & scale *(open milestone; items #31–#35)*

Goal: make bulk usage cheap and survivable, ahead of the fundamentals expansion.
**Gate: v0.6.1 is on CRAN before this milestone opens for development.**

| Issue | Item | Notes |
|-------|------|-------|
| *to be filed* | Cookie/crumb session groundwork | **Promoted from a dash-row to the keystone item**: quoteSummary-family endpoints (all of v0.8.0 WS-2, possibly F-01's timeseries endpoint) are crumb-gated. Deliverables: acquire/reuse/refresh browser-like sessions, document expiry behaviour, wire into the shared request helper, define failure semantics when Yahoo rotates secrets. Own issue + acceptance criteria; lands before any v0.8.0 module work |
| #33 | Disk + session caching via `httr2::req_cache()` | Opt-in per call and via `options()`. Explicit per-data-class TTL policy, documented in `?yf_cache`: live quotes/intraday = seconds-to-minutes; daily-or-coarser history = until end of day (refresh next session); statements/fundamentals = 24 h; slow-moving reference data (currency lists) = 1 week. Document the adjusted-price staleness caveat that made yfR default to session-only caches. **Implementation risk:** Yahoo responses frequently carry `Cache-Control: no-store` / tiny `max-age`, which `req_cache()` obeys — spike the actual headers first; if they defeat caching, intercept parsed responses and key a thin rds store by endpoint+params under the same TTL table. **Sequencing: #33 lands before #34** — parallelism without caching and a rate budget is how IP bans happen |
| #34 | Parallel batch fetching | `furrr` behind an opt-in `do_parallel` argument (Suggests only); respect the shared rate budget — parallelism must not multiply request rates. Sequential execution remains the default and is the documented fallback when furrr is absent; CI exercises both paths |
| #35 | Nightly live canary CI job | Non-blocking scheduled workflow hitting real endpoints for a fixed symbol basket; failure opens an issue automatically. This converts "Yahoo changed something" from user reports to maintainer alerts |
| #31 | `yf_status()` | Connectivity + rate-limit diagnostics helper; reports endpoint reachability, last-canary result, package version |
| #32 | NSE/BSE suffix helper | `yf_nse("RELIANCE")` auto-appends `.NS`. **The accompanying India vignette moves to v0.9.0** — it needs real fundamentals to demonstrate, and its screener.in gap analysis presupposes the analytics tier |
| — | Rate-budget policy | Throttling policy (≤ ~2 req/s sustained default), 429-aware backoff with jitter; document what happens when limits trip. (Crumb mechanics are now tracked as the first-class row above.) |
| — | Documentation-drift guard *(deferred from v0.6.1)* | Automated test cross-referencing exported class members (`Ticker`, `Tickers`, `Index`) against roxygen-documented fields/methods, so docs and surface cannot silently diverge; CI fails if an exported method lacks documentation or docs reference a non-existent member |

Exit criteria: downloading 50 tickers × 2 years takes single-digit seconds warm, minutes cold,
and a Yahoo-side outage produces actionable messages instead of silence.

### 5.3 v0.8.0 — fundamentals data acquisition *(open milestone)*

Goal: build the data moat's foundation. **Rescoped per second-round review: this release ships
the acquisition layer only (statements + quote-summary modules); all computed analytics moved to
v0.9.0 so users get working fundamentals sooner and each release stays reviewable.**
Internal ordering matters: **WS-1 unblocks everything else.**

| WS | Issues | Deliverable | Yahoo Finance source |
|----|--------|-------------|----------------------|
| WS-1 | (prereq for #36–#44) | Statements engine: annual/quarterly income statement, balance sheet, cash flow as tidy tibbles; extends the v0.6.1 minimal fix to full line-item coverage. Documents consolidated-vs-standalone handling (Yahoo returns consolidated data with no explicit flag) and the ~5 yr annual / ~4 yr quarterly depth limit | `fundamentals-timeseries` |
| WS-2 | — | Quote-summary modules: key stats, summary detail, financial data, earnings history + dates, ESG scores, insider transactions, institutional/major holders, upgrade/downgrade history — each a documented tibble; several require the v0.7.0 crumb groundwork | `quoteSummary` modules; `insights`; `timeseries` |

**Acceptance criteria ("done" means):**

- **WS-1:** `Ticker$new("AAPL")$get_income_statement()` (and the balance-sheet / cash-flow
  equivalents) return non-empty, schema-documented tibbles with ≥ 4 annual periods and
  ≥ 12 quarterly periods, live-verified for a fixed basket (AAPL, GOOG, RELIANCE.NS).
- **WS-2:** every listed module returns its documented tibble for the same basket in a live smoke
  test; modules needing crumb auth state that dependency in their docs.

Every deliverable lands with: schema-documented tibble return, fixture-based tests derived from
recorded traffic, README/vignette mention only after live verification.

### 5.4 v0.9.0 (proposed milestone) — computed analytics

Goal: turn the v0.8.0 data moat into value-add scoring. Former work streams WS-3…WS-7, split out
of v0.8.0 because acquisition and computation deserve separate, reviewable releases.

| WS | Issues | Deliverable | Notes |
|----|--------|-------------|-------|
| WS-3 | #36 | Growth/CAGR scorecards: revenue, EPS, margin trajectories across periods | computed over WS-1 |
| WS-4 | #39, #40, #41 | Classic screens as composable functions: `yf_piotroski()`, `yf_altman_z()`, Magic Formula, Graham defensive, Darvas box, momentum, loss-to-profit turnaround, dilution filter. **Every screen returns component-level detail alongside totals** (each Piotroski criterion's pass/fail, each Altman X-term, each ratio input) — never a bare boolean. **Data-depth honesty, up front:** Piotroski/Altman/Magic Formula/Graham remain meaningful within Yahoo's ~5-year annual depth (caveats in docs); the **Coffee Can portfolio (~10-year revenue-growth + ROCE streaks) is essentially unfeasible from Yahoo data alone** — it ships only behind a prominent limitation banner or gets cut at planning time, not demoted to a footnote | computed over WS-1/WS-2 + prices |
| WS-5 | #37 | Ownership/shareholding patterns engine (institutional + insider deltas by quarter; directional FII/DII proxy for India) | holders modules |
| WS-6 | #42, #43 | Automated diagnostics (pros/cons engine à la screener.in's financial x-ray) + peer-comparison matrix built on `Tickers` fan-out | WS-1/WS-2 |
| WS-7 | #44 | Multi-tab Excel financial-model export (`yf_export_workbook()`, openxlsx in Suggests) | composed output |
| — | #32 (vignette) | "Analysing Indian stocks" vignette incl. the honest gap analysis vs screener.in, now that Indian fundamentals exist to demonstrate | WS-1/WS-2 output |

Prerequisite decision before WS-4 starts: **TTR joins Suggests** for the technical screens (#41:
Darvas box, golden/death crossover, RSI), or indicators are hand-rolled if the dependency chain
is judged too heavy. Decide explicitly; don't discover it mid-stream.

### 5.5 v0.10.0 (proposed milestone) — the screener engine

Goal: deliver the capability that defines the north star. Two tiers, deliberately separated:

**Tier 1 — server-side screening (fast path).** Thin R client for Yahoo's screener API — the same
endpoint family `yfinance`'s screener module uses. Universe-wide filtering executes on Yahoo's
infrastructure; results paginate at 250 rows.

- `yf_screen_query(...)`: an R-native DSL mirroring the operators Yahoo accepts
  (`eq`, `gt`, `gte`, `lt`, `lte`, `btwn`, `is-in`, `and`, `or`) over a registered field catalog
  (price, trading, income-statement, balance-sheet, short-interest groups; region/exchange/sector/
  industry equality fields). Design goal: common screens should read like `dplyr::filter()`
  pipelines — sugar helpers (`between(field, lo, hi)`, `in_set(field, ...)`), composition via
  familiar boolean semantics — with raw operator construction available as the escape hatch, so
  the mapping onto Yahoo's wire format stays transparent.
- `yf_screen(query, sort_field, sort_asc, size, offset)`: executes custom queries;
  `yf_screen_predefined("undervalued_growth_stocks", ...)` wraps the ~20 predefined screens;
  `yf_screen_fields()` exposes the field registry for discoverability.
  *(Issue #38 reconciled here — moved out of GitHub's v0.8.0 milestone; see §2.4.)*
- Fixture tests + canary coverage like any other endpoint.
- **Expect breakage:** the endpoint is undocumented and `yfinance` has rewritten its screener
  module repeatedly. Plan and budget for at least one rewrite cycle; Tier 2 is the architectural
  hedge, and both tiers share one DSL.

**Tier 2 — local screening (deep path).** Runs computed metrics Yahoo cannot filter server-side
(Piotroski, Altman Z, custom ratios, technical states) over cached universes.

- Universe management: `yf_universe(name)` resolving index constituents. **Design decision
  recorded:** user-supplied vectors/files are the first-class input; curated index snapshots
  (S&P 500, NIFTY 50/500) ship as maintained data artifacts refreshed periodically; an optional
  scraper utility (à la yfR's reference-source approach) may assist curation, but scraping never
  enters core fetch paths. Snapshots persist so screens are reproducible.
- `yf_run_screen(universe, filters, rank_by, top_n)` executing v0.9.0 analytics functions over the
  cache with progress reporting and graceful per-symbol degradation.
- Persistence hooks default to **rds**; parquet support is strictly opt-in for users who already
  have `arrow` installed (a ~200 MB compiled dependency — never a hard requirement), feeding
  directly into the backend blueprint (`backend_blueprint.md`).

### 5.6 v1.0 — stabilization & community gate

- API freeze pledge: exported signatures stable; deprecation policy published.
- "yahoofinancer vs yfR" comparison vignette (ships once v0.8.0 fundamentals exist, so the
  comparison can be made on substance): price-first workflows vs fundamentals/screening,
  caching models, output schemas — helping users pick the right tool deliberately.
- **rOpenSci: start the pre-submission inquiry when v0.8.0 ships**, not at v1.0 — editor feedback
  on scope and design arrives months earlier that way, and review is itself a 3–6 month process.
  Full submission once robustness criteria hold (live canary green for 60 days, caching +
  rate budgeting shipped, docs audited). The badge measurably moves academic adoption (cf. yfR).
  Reviewers commonly become the first recurring contributors — treat the review as community
  cultivation targeting **1–2 recurring contributors realistically**; ≥ 3 remains a stretch goal,
  not the plan of record.
- Marketing cadence as tracked engineering task, not aspiration: an R-bloggers post per CRAN
  release plus a talk/blog budget alongside milestones (see §9).
- CONTRIBUTING.md, issue-triage rotation. JOSS paper candidacy after rOpenSci, scoped to the
  **architecture** (dual-tier API, tidy contracts, offline-testing strategy) rather than the
  finance domain.

---

## 6. Backend blueprint — extracted to its own document

The screener.in-style service blueprint (architecture, ingestion pipeline, DuckDB + parquet
storage, screen compiler, plumber REST API, operations) now lives in **`backend_blueprint.md`**,
extracted in the 2026-08-24 revision. Rationale: it describes a separate repository/service that
depends on v0.9.0+ package capabilities, and keeping it inside the package roadmap blurred CRAN
scope. Its most important section — **legal and ethical positioning** (private deployment only,
no redistribution, conservative rate budgets by design) — leads that document.

The package remains CRAN-clean and supplies every building block the blueprint consumes:
`yf_download_prices()`, the v0.8.0 fetchers, the `yf_screen_query()` DSL, and the Tier-2 local
screen runner.

---

## 7. Screener.in feature matrix → milestone mapping

Feasibility updated from the superseded review to current architecture.

| Screener.in capability | Feasibility | Source / computation | Lands in |
|------------------------|-------------|----------------------|----------|
| Insider trades, promoter buy/sell tracking | Build | insider-transaction module + ownership deltas | v0.8.0 WS-2 / v0.9.0 WS-5 |
| Peer comparison (side-by-side fundamentals) | Build | `Tickers` fan-out + key stats | v0.9.0 WS-6 (#43) |
| Pros/cons checklist (automated x-ray) | Compute | rules over statements + stats | v0.9.0 WS-6 (#42) |
| 10-year financials | Partial | ~5 yr annual / ~4 yr quarterly from Yahoo; documented limit. **Stated plainly: if 10-year financials are essential to your workflow, this package cannot supply them — combine with manual BSE/NSE imports** | v0.8.0 WS-1 |
| Segment revenue breakdown | Not feasible | not exposed by Yahoo | — |
| Delivery volume % (NSE) | Not feasible | NSE trade-level data | — |
| Credit ratings (CRISIL/ICRA…) | Not feasible | no structured source | — |
| Promoter holding % (SEBI pattern) | Not feasible | regulatory filings, not in Yahoo | — |
| ESG scores | Build | insights/ESG module | v0.8.0 WS-2 |
| Custom ratio builder | Compute | ratio engine over stored statements | v0.10.0 Tier 2 |
| Piotroski F-score | Compute | two consecutive annual periods | v0.9.0 WS-4 (#39) |
| Altman Z-score | Compute | BS + IS inputs | v0.9.0 WS-4 (#39) |
| Magic Formula | Compute | earnings yield + ROIC ranks | v0.9.0 WS-4 (#40) |
| Graham defensive screen | Compute | PE/PB bands (with honesty note on data depth) | v0.9.0 WS-4 (#40) |
| Coffee Can portfolio | Marginal | ~10-yr streaks exceed Yahoo's data depth; ships only behind a prominent limitation banner or gets cut (§5.4) | v0.9.0 WS-4 (#40) |
| 52-week high/low proximity | Build | summary detail + quotes | v0.8.0 WS-2 / v0.9.0 WS-4 (#41) |
| Golden/death crossover, RSI screens | Compute | price history + TTR | v0.9.0 WS-4 (#41) / v0.10.0 |
| Dividend yield screen | Build | summary-detail dividend fields | v0.8.0 WS-2 |
| FCF yield screen | Build | financial-data cashflow × market cap | v0.8.0 WS-2 |
| Quarterly earnings acceleration | Build | earnings-history sign/slope checks | v0.9.0 WS-4 (#41) |
| Loss-to-profit turnaround | Build | EPS sign change Q-1 → Q0 | v0.9.0 WS-4 (#41) |
| Dilution filter / capacity expansion | Compute | shares outstanding, net PP&E across periods | v0.9.0 WS-4 (#41) |
| FII/DII flows | Partial | institutional ownership as directional proxy only — **noisy and indicative, not actionable**; documented as such | v0.9.0 WS-5 (#37) |
| Consolidated vs standalone auto-pick | Partial | Yahoo returns consolidated; no explicit flag — document | v0.8.0 WS-1 note |
| Email/change alerts | Not feasible (pkg) | requires hosted infra; possible later service feature | backend, post-v1 |
| Whole-universe discovery (screener.in "explore") | Build | Yahoo server-side screener | **v0.10.0 Tier 1** |

India-specific UX: the `.NS/.BO` suffix helper ships with v0.7.0 (#32); the
"Analysing Indian stocks" vignette follows in **v0.9.0**, once Indian fundamentals exist to
demonstrate, including the honest gap analysis vs screener.in.

---

## 8. Risks and mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Yahoo hardens further (crumb enforcement everywhere, TLS fingerprinting) | Medium-high | Endpoints fail en masse | v0.7.0 crumb groundwork + impersonation-capable fallback study; canary detects within 24 h; keep request patterns browser-like (versioned UA, sane pacing) |
| Rate-limiting blocks bulk users | Medium | Broken workflows, reputation damage | Global rate budget, mandatory caching defaults for bulk paths, documented limits, `yf_status()` diagnostics |
| ToS exposure as adoption grows | Medium | Cease-and-desist risk for visible misuse | Positioning: research/personal tooling; disclaimers; refuse to build redistribution features; backend blueprint enforces private deployment |
| Bus factor = 1 | High | Abandonment risk on next Yahoo breakage | rOpenSci submission, CONTRIBUTING.md, spec-driven workflow already in `specs/`, canary reduces maintenance surprise cost |
| Scope sprawl across 20+ planned functions | Medium | Half-finished surface | Strict WS ordering in v0.8.0 (statements first); "docs only after live verification" rule; each milestone exits with CRAN release |
| Server-side screener endpoint changes/disappears | Medium | v0.10.0 Tier 1 breaks | Plan for ≥ 1 rewrite cycle (yfinance has rewritten its screener module repeatedly); Tier 2 (local runner over cached universes) is the architectural hedge; both share one DSL |
| Latent R-version floor mismatch (declared R ≥ 3.4 vs httr2's ≥ 4.0) | Certain today | CRAN check confusion / false compatibility claims | Raised to `R (>= 4.1)` in the v0.6.1 lint & floor pass; reassess whenever heavy Suggests land |
| Unversioned upstream API × maintainer patch latency | High over a multi-year horizon | Long outages between releases when bus factor = 1 | Canary detects within 24 h; specs/-driven repair playbook lowers per-fix cost; rOpenSci review + contributor growth widen the pool |
| Dual mocking systems (binding mocks + httptest2) drift apart | Medium | Maintenance burden; F-01-style masking recurs in the legacy system | Single-system policy set during the v0.6.1 mock audit: httptest2 for all new endpoints; legacy binding-mock helpers migrate opportunistically |

---

## 9. Success metrics

| Metric | Baseline (Aug 2026) | Target |
|--------|--------------------:|-------:|
| CRAN downloads/day | ~29 | ≥ 100 by v0.8.0; ≥ 250 within 6 months of v1.0 — **contingent on the marketing cadence (§5.6); organic growth alone historically delivers a fraction of this** |
| GitHub stars | 20 | ≥ 100 by v1.0 — visibility-driven (posts, talks), not quality-driven; treat as a promotion outcome, not an engineering one |
| Time-to-first-value | unmeasured | < 5 min from `install.packages()` to first useful tibble; measured against the quickstart vignette each release |
| Canary MTTR after Yahoo-side breakage | n/a (no canary) | < 48 h detection, patch released < 7 days |
| Test coverage | > 90% (hermetic) | maintain ≥ 90% while surface doubles |
| CRAN check results | 0 errors/warnings/notes | unchanged through all releases |
| Fundamentals coverage | 1 working timeseries endpoint | 10+ documented module surfaces (v0.8.0 exit) |
| Screener capability | none | server-side + local tiers, one DSL (v0.10.0 exit) |
| Community | single maintainer | 1–2 recurring contributors via rOpenSci review (realistic); ≥ 3 is a stretch goal |

---

## Appendix A — Disposition of the superseded review (audits/yahoofinancer-review.pdf)

| PDF item | Status | Where |
|----------|--------|-------|
| Phase 1: functional wrappers, hide R6 | Done in v0.6.0 (partially — see F-01) | §5.1 completes it |
| Phase 1: quick-start vignette without R6 | Done (`first-stock-analysis`, `comparing-portfolios`) | — |
| Phase 2: migrate httr → httr2 | Done in v0.6.0 (#27) | §2.1 |
| Phase 2: retry/backoff | Done (req_retry, exponential backoff) | §2.1 |
| Phase 2: actionable error messages | Partial; boilerplate still duplicated | §5.1 (E-01) |
| Phase 2: optional cache | Open (#33) | §5.2 |
| Phase 2: live canary CI | Open (#35) | §5.2 |
| Phase 2: `yf_status()` | Open (#31) | §5.2 |
| Phase 3: task-oriented vignettes | 3 exist (incl. 15-recipe cookbook); screening/Shiny/forex pending data layer | §5.3–§5.5 |
| Phase 3: document every property w/ schema | Pending — blocked by missing members (§2.3) | §5.3 |
| Phase 3: cheat sheet, R-bloggers posts, CONTRIBUTING.md, issue triage | Open | v0.8.0–v1.0 community track |
| Phase 3: rOpenSci submission | Pre-submission inquiry at v0.8.0; full submission deferred until robustness gate met | §5.6 |
| Phase 4: parallel fetch | Open (#34) | §5.2 |
| Phase 4: index constituents | Expanded into universe management | §5.5 Tier 2 |
| Phase 4: persistent on-disk cache | Open (#33) | §5.2 |
| Phase 4: options chain | Carried forward, unscheduled (low priority vs screener) | backlog candidate |
| Phase 4: JOSS paper | Carried forward after rOpenSci | §5.6 |
| Recipes referencing nonexistent members (`key_stats`, `esg_scores`, …) | Stale — reinterpreted as the v0.8.0 target API | §2.3 |
| Screener.in feasibility matrix + templates + India analysis | Absorbed | §7 |
