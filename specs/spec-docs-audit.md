### Task: Comprehensive API Documentation Audit (Read-Only Mode)

#### Role & Objective
Act as a senior R package architect, documentation specialist, and CRAN reviewer. Perform an exhaustive audit of all user-facing and internal API documentation across this package. 

**Important Constraint**: Do NOT modify any existing source code, roxygen comments, vignettes, or config files right now. Perform a read-only review and write your entire report and concrete recommendations into a new file: `docs_audit_opus.md`.

---

### Audit Scope & Files to Inspect
* `R/`: All R scripts and roxygen2 docblocks.
* `man/`: Generated `.Rd` files.
* `_pkgdown.yml`: Site layout, navbar structure, and reference index organization.
* `vignettes/`: Vignette documentation and code examples.
* `README.md` / `README.Rmd`: Quickstart guides and exported function references.
* `NAMESPACE`: Exported vs. internal functions.

---

### Audit Dimensions & Evaluation Criteria

1. **Parameter Accuracy & Interface Consistency**
   - Check consistency between functional helpers (e.g., `yf_download_prices()`, `yf_get_financials()`, `yf_get_index_quotes()`) and R6 classes (`Ticker`, `Indice`).
   - Audit parameter naming parity (e.g., `start`/`end`, `interval`, `period`).
   - Ensure all valid choices for discrete arguments (e.g., valid intervals `"1d"`, `"1m"`, periods `"1mo"`, `"1y"`, ISO currency codes) are explicitly enumerated in `@param` tags.

2. **Return Value Contract Specifications (`@return`)**
   - Verify every public function explicitly describes its exact return type (e.g., `tibble`, named list, atomic vector, R6 instance).
   - Ensure column schemas (column names, types, descriptions) are documented for tabular outputs.
   - Specify return behavior on edge cases (empty results, bad tickers, network failures).

3. **Examples Quality & CRAN Compliance (`@examples`)**
   - Verify that all examples making external network calls are wrapped in `\dontrun{}` to prevent automated check timeouts.
   - Confirm examples use modern tidyverse idioms and demonstrate realistic workflows (e.g., single ticker, batch tickers, custom dates).

4. **Cross-Referencing, Families & Internal Tags**
   - Verify `@family` tags group related functions logically in documentation indices.
   - Ensure helper functions not intended for end users have `@keywords internal` or are excluded from `@export`.

5. **`pkgdown` Reference Index Completeness (`_pkgdown.yml`)**
   - Audit all exported `.Rd` topics to ensure none are missing from `reference:` in `_pkgdown.yml`.
   - Check category grouping logic for clarity and user discoverability.

6. **API Constraints & Edge Cases**
   - Verify that upstream constraints (e.g., Yahoo Finance lookback limits on intraday 1m/5m data, rate limits) are clearly documented.

---

### Output Requirements: `docs_audit_opus.md`

Generate and write the complete audit into `docs_audit.md` structured as follows:

1. **Executive Summary**: High-level health assessment of current package documentation.
2. **Audit Findings Matrix**:
   | Topic / Function | File | Issue Category | Severity (High / Med / Low) | Summary of Finding |
   | :--- | :--- | :--- | :--- | :--- |
3. **File-by-File Recommended Changes**:
   - Provide exact, ready-to-use Roxygen2 blocks showing proposed replacements for every function needing improvement.
   - Provide the complete recommended `_pkgdown.yml` reference configuration.
4. **Actionable Implementation Checklist**:
   - Ordered step-by-step checklist to apply changes, re-document via `devtools::document()`, and test with `pkgdown::build_site()`.
