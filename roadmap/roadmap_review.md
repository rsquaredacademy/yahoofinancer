# Review and Suggestions for `yahoofinancer` Roadmap

The roadmap provides an exceptionally clear, comprehensive, and realistic plan for the package's evolution. It correctly identifies the critical gaps (especially the shipped-but-broken features) and outlines a pragmatic path to establishing `yahoofinancer` as the premier R package for fundamental analysis and screening.

Here are specific feedback and suggestions organized by roadmap sections:

## 1. State of the Package & Defect Register
*   **F-01 (Broken Financials):** Prioritizing this is absolutely correct. The fact that the test suite masks this failure highlights a critical danger of mocking: **mocking systems must not invent API surfaces**. 
    *   *Suggestion:* As part of the v0.6.x fix, audit the `helper-mocks.R` and `httptest2` fixtures to ensure no other non-existent methods or endpoints are being simulated. Add a policy that mocks must be generated from real API responses, not hand-crafted to pass tests.
*   **E-02 (Silent Error Swallowing):** Returning empty tibbles on failure is much better than silent `NULL`s, provided it's paired with an informative warning naming the failed symbol.

## 2. Competitive Landscape & Positioning
*   The comparison against `yfR` and Python's `yfinance` is spot on. R lacks a robust fundamentals and screening tool. Focusing on this "wedge" provides a clear unique selling proposition.
*   *Suggestion:* Explicitly document the differences between `yahoofinancer` and `yfR` in a vignette (e.g., "yahoofinancer vs yfR") so users know exactly which tool to reach for. 

## 3. Roadmap Milestones

### v0.6.x (Immediate Fixes)
*   Treating this as a hotfix track to enforce truthfulness in the API surface is the right move before adding new features.
*   *Suggestion:* Add an automated test that cross-references the exported `Ticker` methods against the documented ones, if possible, to prevent future drift.

### v0.7.0 (Reliability & Scale)
*   **Caching & Parallelism:** Implementing caching *before* or alongside parallelism is crucial. Parallelism without caching or rate-limiting will quickly lead to IP bans from Yahoo.
*   **Canary CI:** The nightly live canary is the most important infrastructural addition for an unofficial API wrapper.
*   *Suggestion:* For the cache, ensure clear TTL (Time To Live) strategies are implemented and documented. Intraday data needs a different TTL than daily historical data or annual fundamentals.

### v0.8.0 (Fundamentals & Analytics)
*   The breakdown into Work Streams (WS-1 to WS-7) provides a clear dependency graph. Getting WS-1 (Statements) right unblocks the complex analytics.
*   *Suggestion:* When implementing standard screens (Piotroski, Altman Z), ensure the functions clearly report *why* a stock passed or failed (e.g., returning the individual components of the F-score alongside the total score), rather than just a boolean.

### v0.9.0 (Screener Engine)
*   The two-tier approach (Server-side Tier 1 + Local Tier 2) is excellent. It leverages Yahoo's backend for broad filtering while retaining R's analytical power for complex, custom metrics.
*   *Suggestion:* For Tier 1 (Server-side), ensure the query DSL (`yf_screen_query`) closely mirrors tidyverse semantics (like `dplyr::filter`) where possible, to reduce cognitive load for R users.

## 4. Backend Blueprint
*   The proposed architecture (DuckDB + Parquet + Plumber) is modern, lightweight, and perfectly suited for this scale. 
*   *Suggestion:* When designing the ingestion workers, consider adding circuit breakers. If Yahoo changes an endpoint and returns 100% errors, the ingestion pipeline should halt and alert rather than aggressively retrying and getting blocked.

## Conclusion
This roadmap serves as a solid foundation. The most critical immediate step is executing the v0.6.x hotfixes to restore the integrity of the advertised features and testing infrastructure.
