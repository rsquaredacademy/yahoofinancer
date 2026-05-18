# Implementation Plan: Test Coverage Hardening

**Branch**: `refactor/hardening-and-coverage` | **Date**: 2026-05-15 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `F:\R\Packages\finance\yahoofinancer\specs\001-coverage-hardening\spec.md`

## Summary

Implement a rigorous test suite using `httptest2` and `testthat` to achieve 90-100% code coverage for `ticker.R`, `indice.R`, `tickers.R`, and `utils.R`. This phase focuses on hardening the codebase before planned refactoring by exercising API error branches, currency conversion logic, and utility edge cases. All tests will be strictly hermetic (offline).

## Technical Context

**Language/Version**: R (>= 3.4)  
**Primary Dependencies**: `R6`, `jsonlite`, `purrr`, `httr` (DESCRIPTION) vs `httr2` (Constitution) → **NEEDS CLARIFICATION**  
**Storage**: N/A  
**Testing**: `testthat` (>= 3.0.0), `httptest` (DESCRIPTION) vs `httptest2` (Constitution) → **NEEDS CLARIFICATION**  
**Target Platform**: CRAN (Cross-platform)
**Project Type**: library  
**Performance Goals**: N/A (Focus on correctness and coverage)  
**Constraints**: 90-100% coverage for target files, offline-capable testing, CRAN compliance
**Scale/Scope**: Refactor hardening for `ticker.R`, `indice.R`, `tickers.R`, and `utils.R`.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Gate | Status | Rationale |
|------|--------|-----------|
| CRAN Submission Compliance | ✅ | Using `::` and avoiding global state is standard practice. |
| R6 Class Consistency | ✅ | Maintaining `public`/`private` and `self$index` (temporary) as per spec. |
| Defensive Programming | ✅ | Testing `stop(..., call. = FALSE)` and input validation. |
| Strict Hermetic Testing | ✅ | Using `httptest2` (pending clarification) and `without_internet()`. |
| Data Structure Consistency | ✅ | Ensuring `tibble`/`data.frame` returns with `snake_case`. |

## Project Structure

### Documentation (this feature)

```text
specs/001-coverage-hardening/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
└── tasks.md             # Phase 2 output (created by /speckit.tasks)
```

### Source Code (repository root)

```text
R/
├── ticker.R
├── indice.R
├── tickers.R
└── utils.R

tests/
└── testthat/
    ├── test-ticker.R
    ├── test-index.R
    ├── test-tickers.R
    └── test-utils.R
```

**Structure Decision**: Standard R package structure with tests in `tests/testthat/`.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| N/A | | |
