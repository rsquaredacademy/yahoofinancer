# yahoofinancer Backend Blueprint — screener.in-style service on Yahoo data

**Status:** Companion document to `roadmap.md`. Extracted from the roadmap's §6 in the
2026-08-24 revision (second-round review): this describes a separate repository/service that
depends on the package's v0.9.0+ capabilities; keeping it inside the package roadmap blurred
CRAN scope. The package remains CRAN-clean and supplies every building block consumed here.

---

## 1. Scope and goals

**Scope:** backend only (as screener.in would be without its UI): data pipeline, storage, and a
screen-execution API consumed by future frontends, scripts, or Shiny apps. Lives in a separate
repository/service.

Goals: reproducible daily snapshots of a configured universe; historical statements + prices in
queryable storage; arbitrary screen execution via the same DSL as `yf_screen()`; simple REST
surface. Non-goals: real-time streaming; data redistribution; public multi-tenant hosting
(ToS constraint, §2); alerting/email (out of scope until a hosting story exists).

---

## 2. Legal and ethical positioning

*Promoted ahead of the technical design in the 2026-08-24 revision: this is the most important
section. Yahoo Finance data is unofficial and personal/research-use, and ToS enforcement is real —
any hosted service multiplies exposure.*

Yahoo Finance data is unofficial and personal/research-use. Consequences for the blueprint:

- Private deployment (personal server/lab), never offered as a public commercial service.
- No redistribution of raw datasets; consumers query, they don't bulk-export.
- Conservative rate budgets and caching as a design principle, not an optimization.
- Prominent disclaimer mirroring the package's: not affiliated with Yahoo; accuracy = Yahoo's.
- Refuse to build redistribution features even if requested.
- Features dependent on SEBI regulatory filings (promoter holding %, FII/DII splits, delivery
  volume %, credit ratings) remain out of scope — see roadmap §7.

---

## 3. Architecture

```
                ┌─────────────────────────────────────────────────┐
                │                 service process                 │
                │                                                 │
 yahoofinancer ─┤  scheduler ─► ingestion workers ─► transformers │
 (data layer:   │      │        (rate-budgeted)     │             │
  fetch, parse, │      ▼                            ▼             │
  screen fns)   │  universe registry          staging area        │
                │                                     │            │
                │              ┌──────────────────────▼───────┐    │
                │              │  store: DuckDB + parquet      │    │
                │              │  prices · statements · quotes │    │
                │              │  ownership · screen results   │    │
                │              └──────────────────────┬───────┘    │
                │                                     │            │
                │  screen compiler (DSL ► SQL/DuckDB) │            │
                │         │                           │            │
                │         ▼                           ▼            │
                │  local screen runner ◄────── plumber REST API    │
                └─────────────────────────────────────────────────┘
                          ▲                        ▲
                      cron/systemd           consumers (Shiny,
                      refresh jobs           scripts, notebooks)
```

---

## 4. Components

1. **Universe registry.** Declarative config (TOML/YAML) listing universes (index constituents,
   curated lists) and per-universe refresh cadence. Constituent membership snapshotted on each run
   so historical screens reflect period-correct membership.
2. **Ingestion pipeline.** Wraps `yf_download_prices()` and v0.8.0 fetchers with: incremental
   updates (fetch only missing dates — mirrors yfR's cache-gap logic), idempotent upserts,
   per-run manifests, and integrity checks (row-count deltas, OHLC sanity, currency consistency).
   All traffic flows through the package's rate-budgeted request engine; a global token bucket
   (default ≤ 2 req/s, jittered backoff on 429) sized for overnight windows keeps the service
   polite and unblocked. **Circuit breakers** guard every endpoint family: when the rolling
   failure rate crosses a threshold (e.g., > 50% errors over the last N requests), ingestion for
   that family halts immediately, the run is marked degraded, maintainers are alerted (log +
   issue), and retries resume only after a cool-down — preventing retry storms during Yahoo-side
   incidents and protecting the shared IP reputation.
3. **Storage.** Parquet files partitioned by `(symbol, year)` for prices/statements; DuckDB as the
   query engine (zero-infra, SQL-native, reads parquet directly). Metadata (runs, manifests,
   universe snapshots, screen definitions) in SQLite. Rationale: no server to operate; scales to
   tens of millions of rows comfortably; trivial backup = copy directory.
4. **Screen compiler.** Compiles the `yf_screen_query()` DSL into SQL against derived views
   (ratios, growth rates, technical states materialized nightly). Falls back to the package's
   in-memory runner for metrics not expressible in SQL. Same semantics either way — one test suite
   asserts parity on sample screens.
5. **REST API (plumber).**

   | Endpoint | Purpose |
   |----------|---------|
   | `GET /health` | version, last successful run per universe, rate-budget state |
   | `GET /universes` · `GET /universes/{id}` | available universes + snapshot metadata |
   | `GET /symbols/{symbol}/prices?from=&to=` | stored price history |
   | `GET /symbols/{symbol}/financials/{statement}?freq=` | stored statements |
   | `POST /screens/run` | execute stored or inline screen DSL; returns ranked matches |
   | `GET /screens` · `PUT /screens/{id}` | manage saved screens (the screener.in "custom screen" analogue) |

6. **Operations.** Structured logging, run manifests retained per refresh, backfill command
   (`service backfill --universe nifty500 --from 2015`), and a documented recovery path
   (delete parquet partition + re-ingest).

---

## 5. Build order

1. Storage + ingestion for one universe (NIFTY 500 or S&P 500) with daily incremental refresh.
2. Screen compiler MVP over stored data (reuse the screener-engine Tier-2 filters).
3. Plumber API around it; containerize (single Docker image, volume-mounted store).
4. Multi-universe, saved screens, manifests/dashboards.
