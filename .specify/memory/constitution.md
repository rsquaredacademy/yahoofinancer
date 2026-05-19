<!--
Sync Impact Report:
- Version change: Unversioned -> 1.0.0
- Modified principles:
  - I. CRAN Submission Compliance (Added)
  - II. R6 Class Consistency (Added)
  - III. Defensive Programming (Added)
  - IV. Strict Hermetic Testing (Added)
  - V. Data Structure Consistency (Added)
- Removed sections: Original placeholders removed
- Templates requiring updates: ✅ None
- Follow-up TODOs: None
-->
# yahoofinancer Constitution

## Core Principles

### I. CRAN Submission Compliance
All code must adhere to strict CRAN policies to ensure successful acceptance and updates to the central repository.
Namespace external functions explicitly using `::` (e.g., `tibble::as_tibble()`). Never modify global state, use `options()`, `setwd()`, or `.GlobalEnv`.

### II. R6 Class Consistency
Maintain structural integrity across all R6 classes to ensure a predictable API and internal logic.
Maintain strict separation between `public` (API surface) and `private` (data parsing/URL) methods. `initialize` methods must validate symbols. Classes must be `portable = TRUE` and `cloneable = TRUE`. All methods require comprehensive Roxygen `@description`, `@param`, and `@return` tags.

### III. Defensive Programming
Implement robust handling of HTTP requests and errors to fail gracefully and informatively.
Validate inputs rigorously. When handling errors, strictly require `stop(..., call. = FALSE)` to provide clean, user-friendly error messages. Ensure defensive strategies when using `curl` and `httr`/`httr2`.

### IV. Strict Hermetic Testing
Tests must be isolated and reliable to avoid flaky test suites and network dependencies during execution.
Tests must NEVER make live internet calls. Mock all network interactions using `httptest2::with_mock_dir()`. Enforce offline testing with `httptest2::without_internet()`. Target 100% line coverage for core files like `R/ticker.R`.

### V. Data Structure Consistency
Predictable return types ease the cognitive load for end-users relying on the package.
Always return data consistently as `tibble` or `data.frame` with `snake_case` column names. Follow the Tidyverse style guide with 2-space indentation.

## Testing Requirements

Ensure exhaustive testing of all components to guarantee stability.
Focus on testing edge cases like empty JSON responses, malformed data, 404/500 API errors, and varied date formats (strings, Date objects, POSIXct). Do not test with live data.

## Implementation Standards

Maintain strict adherence to R programming best practices.
Do not use top-level code execution on load. Verify that all components have zero reliance on hidden side effects. 

## Governance

All Pull Requests and code reviews must verify compliance with CRAN policies and hermetic testing mandates before merging. Changes to this constitution require a version bump according to semantic versioning. Use `.gemini/GEMINI.md` for runtime development guidance.

**Version**: 1.0.0 | **Ratified**: 2026-05-15 | **Last Amended**: 2026-05-15
