# Roadmap Feedback — yahoofinancer

**Date:** 2026-08-24
**Reviewed:** `roadmap.md`
**Cross-referenced against:** GitHub milestones/issues, codebase (R/ directory), NEWS.md, DESCRIPTION, specs/

---

## Overall Assessment

The roadmap is exceptionally well-written — one of the most thorough package roadmaps I've seen in the R ecosystem. The defect register is honest, the competitive analysis is sharp, and the north-star vision (tidy fundamentals + screening) is genuinely differentiated. The phased approach (fix foundations → reliability → fundamentals → screener) is the right order.

That said, pragmatic execution requires sharpening several areas. Below is section-by-section feedback, organized as: **what works**, **what needs attention**, and **concrete suggestions**.

---

## 1. GitHub ↔ Roadmap Alignment Issues

**The roadmap and GitHub issue tracker have drifted apart. Several items exist only in one place.**

### Issues the roadmap references but GitHub doesn't track

| Roadmap Item | Roadmap Section | GitHub Status |
|---|---|---|
| v0.6.x hotfix track (all items) | §5.1 | **No milestone exists.** No issues filed for F-01 fix, mock audit, drift guard, HTTP unification, failure contract, batch validation, date hygiene, or lint pass |
| `yf_status()` (#31) | §5.2 | #31 exists but is **not in the v0.7.0 milestone** — only #33, #34, #35 are |
| NSE/BSE suffix helper (#32) | §5.2 | #32 exists but is **not in the v0.7.0 milestone** |
| Rate-limit resilience / crumb groundwork | §5.2 | No issue filed |
| v0.9.0 screener engine (both tiers) | §5.4 | No milestone or issues exist |
| v1.0 stabilization | §5.5 | No milestone or issues |

### Milestone placement conflicts

| Item | Roadmap says | GitHub says |
|---|---|---|
| `yf_screen` (#38) — Screener Query Engine | v0.9.0 (§5.4) | **v0.8.0 milestone** |
| v0.6.0 milestone | "complete" / "closed" | GitHub shows it as **open** (all 7 issues closed, but milestone itself not closed) |

### Suggestions

1. **Create a v0.6.1 milestone** on GitHub for the §5.1 hotfix items. File individual issues for each (F-01, mock audit, HTTP unification, etc.) — they're distinct deliverables that need tracking. Right now the most critical work has no issue trail.
2. **Move #31 and #32 into the v0.7.0 milestone** on GitHub to match the roadmap.
3. **Move #38 out of v0.8.0** and into a new v0.9.0 milestone, or update the roadmap to place the screener DSL in v0.8.0 instead. Pick one — the contradiction is confusing.
4. **Close the v0.6.0 milestone** on GitHub. It's 100% done but showing as open.
5. **Create stub issues for the crumb/rate-limit work** — even if they're placeholders, they need to be trackable.

---

## 2. v0.6.x — The Hotfix Track (§5.1)

### What works

- Correctly identifies F-01 as the critical-path blocker. Everything else is devalued if the README lies about financial statements.
- The mock-surface audit policy ("mocks derive from captured live traffic") is exactly the right lesson from F-01. This should be a first-class contribution guideline.
- Grouping all the "make what's shipped actually work" items into a hotfix track is the right call — these aren't features, they're bugs.

### Concerns

1. **This is not "small-to-medium" effort.** The roadmap lists 8 distinct deliverables in §5.1, several of which are multi-file refactors (HTTP unification touches 5 files; the lint pass touches everything). Be honest about sizing — this is probably 3-4 weeks of focused work, not a weekend sprint.

2. **F-01 has hidden complexity.** The `fundamentals-timeseries` endpoint that the roadmap prescribes is a different API surface than the old `quoteSummary` modules. It returns data in a completely different structure (time series by field, not by statement). The implementation needs:
   - Discovery of which `fundamentals-timeseries` type codes map to which line items
   - A pivot from Yahoo's columnar format to the row-per-period tibble the `yf_get_financials()` API implies
   - Crumb/cookie authentication (this endpoint is crumb-gated as of 2025)

   This means F-01 *cannot be fully fixed without the v0.7.0 crumb groundwork*. The roadmap should explicitly acknowledge this dependency or scope the v0.6.x fix to what's achievable without crumb auth.

3. **The drift guard (CI test cross-referencing exports vs docs)** is a nice idea but low-priority compared to the other items. It prevents future regressions but doesn't fix any current bug. Consider deferring it to v0.7.0.

4. **The lint pass should be last**, after all other v0.6.x items land. Linting before a refactor creates merge conflicts and churn.

### Suggested ordering within v0.6.x

```
1. F-01 fix (financial statements) — blocks README honesty
2. HTTP/error unification (E-01) — blocks failure contract
3. Failure contract (E-02/E-05) — blocks trust
4. Batch validation (E-03 partial) — quick win
5. Date hygiene (E-04) — quick win
6. Mock-surface audit — validates the fix
7. Lint pass (E-06) — last, after all changes land
8. Drift guard — defer to v0.7.0
```

---

## 3. v0.7.0 — Reliability & Scale (§5.2)

### What works

- The sequencing rule "#33 before #34" (caching before parallelism) is exactly right. Parallel requests without caching or rate budgets is how you get blocked.
- The live canary CI job is high-value and often overlooked. Good call.
- The exit criterion ("50 tickers × 2 years in single-digit seconds warm") is measurable and user-centric.

### Concerns

1. **The crumb/cookie groundwork is buried as a dash-item** ("—" row, no issue number). This is arguably the *most important* item in v0.7.0 — it unblocks quoteSummary-based endpoints that the entire v0.8.0 depends on. It should have its own issue and clear acceptance criteria.

2. **`httr2::req_cache()` may not be sufficient.** Yahoo's API responses often include `Cache-Control: no-store` or short `max-age` values, which means `req_cache()` respects those headers and won't actually cache. You may need a custom caching layer on top (intercept the parsed response, key by endpoint+params, store in rds with your own TTL logic). The roadmap's TTL policy table is great but should note this implementation risk.

3. **`furrr` as the parallelism backend adds a heavy dependency chain** (furrr → future → globals → listenv). For a CRAN package that targets broad adoption, consider:
   - Making `furrr` optional via Suggests (already planned, good)
   - Documenting what happens when `furrr` isn't installed (sequential fallback, which should be the default)
   - Testing both paths in CI

4. **The India vignette (#32) feels out of place in v0.7.0.** This is documentation/UX, not reliability engineering. It could ship with v0.8.0 instead, once there's actually fundamental data to show for Indian stocks. A `.NS`/`.BO` suffix helper function is fine for v0.7.0, but the full vignette with "honest gap analysis vs screener.in" is premature until the screener story exists.

5. **Missing: v0.7.0 should include the CRAN release of v0.6.x fixes.** The hotfix items from §5.1 need to ship to CRAN before v0.7.0 development begins. The roadmap doesn't mention a CRAN submission step between milestones.

---

## 4. v0.8.0 — Fundamentals & Analytics (§5.3)

### What works

- The WS ordering (statements engine first, everything else depends on it) is correct and clearly stated.
- "Every screen returns component-level detail alongside totals" is excellent API design — never a bare boolean.
- The Excel export (WS-7) being last and in Suggests-only is the right priority.

### Concerns

1. **v0.8.0 is far too large for a single milestone.** It contains 7 work streams, 9 GitHub issues, spanning financial statements, 10+ quoteSummary modules, 6 different scoring algorithms, an ownership engine, a diagnostic engine, a peer comparison matrix, and an Excel exporter. At the current pace (single maintainer, ~2 commits/week based on 223 commits over the repo's life), this is 4-6 months of work *minimum*.

   **Suggestion:** Split v0.8.0 into two milestones:
   - **v0.8.0** — Statements engine (WS-1) + quoteSummary modules (WS-2) = the data acquisition layer
   - **v0.8.5 or v0.9.0** — Computed analytics (WS-3 through WS-7) = the value-add layer

   This gives users working fundamentals sooner and makes each release reviewable for rOpenSci.

2. **The screener query engine (#38) is in v0.8.0 on GitHub but v0.9.0 in the roadmap.** This needs to be resolved. If `yf_screen` is a server-side API wrapper, it's closer to WS-2 (another Yahoo endpoint) than to the computed analytics. It could go either way, but it needs a decision.

3. **Piotroski, Altman Z, Graham, Coffee Can all require robust financial statement data.** If WS-1 delivers only ~5 years of annual data (Yahoo's limit), some of these scores are borderline meaningful. The roadmap acknowledges this ("documenting the ~5-year annual-data limit") but should be more explicit about which scores become unreliable with short histories. Coffee Can (10-year revenue CAGR + ROCE) is essentially unfeasible with Yahoo data alone — say so upfront rather than shipping a footnote.

4. **TTR dependency for technical screens (#41) is unlisted.** The Darvas box, golden/death crossover, and RSI screens require TTR (or a manual calculation). TTR should be added to Suggests in the plan.

5. **No acceptance criteria specified per WS.** Each work stream should have concrete "done" criteria similar to the exit criteria for v0.7.0. For example: "WS-1 is done when `Ticker$new('AAPL')$get_income_statement()` returns a non-empty tibble with >= 4 annual periods and >= 12 quarterly periods."

---

## 5. v0.9.0 — The Screener Engine (§5.4)

### What works

- The two-tier architecture (server-side fast path + local deep path) is smart and creates a natural fallback.
- The DSL design goal ("common screens should read like `dplyr::filter()` pipelines") is exactly right for the R audience.
- Universe management with persisted snapshots for reproducibility is a strong differentiator.

### Concerns

1. **The server-side screener API is undocumented by Yahoo and could change at any time.** The roadmap's risk table (§8) acknowledges this but understates the mitigation. `yfinance` has had to rewrite its screener module multiple times. Plan for at least one breakage cycle.

2. **"yf_universe" resolving index constituents** is harder than it sounds. Yahoo doesn't expose a reliable "give me all S&P 500 members" endpoint. `yfR` solves this by scraping Wikipedia/reference sources and hardcoding index compositions. The roadmap should decide: scrape, hardcode, or require user-supplied lists? Each has different maintenance costs.

3. **Parquet/rds persistence hooks** imply the `arrow` package in Suggests. That's a ~200MB compiled dependency — non-trivial for users on restricted systems. Consider defaulting to rds and offering parquet as an opt-in for users who already have arrow installed.

---

## 6. v1.0 & rOpenSci (§5.5)

### What works

- "60 days of green canary" as the rOpenSci submission gate is a good measurable criterion.
- The comparison vignette being deferred until there's substance to compare is wise — don't ship empty marketing.

### Concerns

1. **rOpenSci review is a 3-6 month process** with extensive back-and-forth on API design, documentation, and testing standards. Start the pre-submission inquiry early (even at v0.8.0 stage) to get editor feedback on scope and design before committing to the full review.

2. **The ">= 3 recurring contributors" target is aspirational** for a niche finance package with 20 stars. More realistic: aim for 1-2 contributors via rOpenSci review itself (reviewers often become contributors). CONTRIBUTING.md and good first issues are necessary but not sufficient — active community cultivation (blog posts, conference talks, social media) drives contributors.

3. **JOSS paper candidacy** should be explicit about scope. JOSS papers describe software, not science. The paper should focus on the architecture (dual API, tidy contracts, offline testing strategy) rather than the finance domain.

---

## 7. Backend Blueprint (§6)

**This section is interesting as a vision document but premature for the roadmap. It describes a separate project (separate repo, separate service) that depends on v0.9.0 being complete.**

### Suggestions

1. **Move §6 to a separate document** (e.g., `backend_blueprint.md`). Its presence in the package roadmap creates the impression that the package is responsible for a DuckDB+plumber service, which muddies CRAN scope.

2. **The legal section (§6.5) is the most important part** and should be more prominent. Yahoo ToS enforcement is real — `yfinance` has faced cease-and-desist pressure, and any hosted service multiplies exposure.

3. **DuckDB + parquet is the right storage choice** for this use case. No notes there.

---

## 8. Screener.in Feature Matrix (§7)

### What works

- The honest "Not feasible" column (segment revenue, delivery volume %, credit ratings, promoter holding %) is refreshingly candid. Don't promise what you can't deliver.
- Mapping each capability to a specific milestone/WS creates accountability.

### Concerns

1. **The "Partial" items need more qualification.** "FII/DII flows" as "directional proxy only" from institutional ownership — how directional? If the signal is too noisy to be actionable, call it "Not feasible" rather than "Partial." Users will expect it to work if it's listed.

2. **"10-year financials: Partial (~5 yr annual / ~4 yr quarterly from Yahoo)"** — this is arguably the single biggest limitation vs screener.in, which has BSE/NSE 10-year data. The roadmap should be more explicit: *"If 10-year financials are essential to your workflow, this package cannot help. Consider combining with manual BSE data imports."*

---

## 9. Risks (§8)

### What works

- The risk register is realistic. "Bus factor = 1" with likelihood "High" is honest.
- "Scope sprawl across 20+ planned functions" with the mitigation of strict WS ordering is sound.

### Missing risks

1. **R >= 3.4 compatibility.** DESCRIPTION requires R >= 3.4 (2017), but httr2 requires R >= 4.0, and the native pipe `|>` requires R >= 4.1. This is already a latent inconsistency. New features (furrr, arrow) will push the floor higher. Decision needed: raise the floor to R >= 4.1 or maintain compatibility testing for old R versions?

2. **Yahoo API versioning.** Yahoo doesn't version its API — any endpoint can change without notice. The roadmap assumes endpoint stability for planning purposes. The canary mitigates detection time, but the *response time* to fix breakage depends on maintainer availability (bus factor = 1 again).

3. **Test suite fragility.** The dual mocking system (custom helper + httptest2) is a maintenance burden. Every new endpoint requires choosing which system to use and potentially maintaining fixtures in two formats. The roadmap's "one mocking policy" should extend to "one mocking system."

---

## 10. Success Metrics (§9)

### What works

- The metrics are measurable and time-bound.
- Canary MTTR is a genuinely useful operational metric.

### Concerns

1. **">= 100 downloads/day by v0.8.0" is ~3.5x current.** Is this achievable without marketing? The package won't market itself — consider adding "blog post on R-bloggers at each CRAN release" as an explicit task, not just a v1.0 aspiration.

2. **">= 100 GitHub stars by v1.0"** requires active promotion. Stars correlate more with visibility (blog posts, Twitter/Mastodon, conference talks) than with package quality. Budget for marketing effort, not just engineering.

3. **Missing metric: time-to-first-value for new users.** How quickly can someone go from `install.packages("yahoofinancer")` to having useful data in their R session? This is the real adoption driver. Measure it and optimize for it.

---

## 11. Packaging & Infrastructure Nits

1. **`httptest` (not httptest2) is still in Suggests** — the roadmap mentions dropping it (E-06) but this hasn't happened. Low priority but easy to forget.

2. **`roadmap.md` itself needs to be in `.Rbuildignore`** — otherwise it'll show up as a CRAN "top-level files" NOTE. Same for `AGENTS.md` and `GEMINI.md` if not already excluded.

3. **The `docs/` committed pkgdown site** is mentioned in AGENTS.md as a known pattern, but it adds significant weight to the repo. Consider moving to GitHub Actions pkgdown deployment (the pattern most pkgdown users have adopted) to keep the repo lean.

4. **NEWS.md has no entry for the v0.6.0 work** that's already landed (httr2 migration, functional API, Tickers class, hermetic tests). The development version header is empty. This should be filled in before the next CRAN submission.

---

## 12. Summary of Prioritized Suggestions

### Do now (before any new features)

1. File GitHub issues for all §5.1 items; create a v0.6.1 milestone
2. Fix F-01 (financial statements) — the README is lying
3. Close the v0.6.0 GitHub milestone
4. Reconcile #38 (screener) placement between roadmap and GitHub

### Do soon (v0.7.0 prep)

5. Promote crumb/cookie groundwork from dash-item to a first-class issue
6. Move #31 and #32 into the v0.7.0 GitHub milestone
7. Investigate `httr2::req_cache()` vs custom caching (does Yahoo send no-store headers?)
8. Raise R minimum to >= 4.1 (or consciously decide not to)

### Do eventually (structural)

9. Split v0.8.0 into two milestones (data acquisition vs computed analytics)
10. Move §6 (backend blueprint) to a separate document
11. Start rOpenSci pre-submission inquiry at v0.8.0
12. Adopt a single mocking system (recommend httptest2 everywhere)
13. Plan marketing cadence: R-bloggers post per CRAN release

---

*Feedback by: code review session, 2026-08-24*
