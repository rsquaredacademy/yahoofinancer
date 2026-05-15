# Implementation Plan: Test Coverage Hardening

**Branch**: `001-hardening-and-coverage` | **Date**: 2026-05-15 | **Spec**: [specs/001-coverage-hardening/spec.md](specs/001-coverage-hardening/spec.md)
**Input**: Feature specification from `/specs/001-coverage-hardening/spec.md`

## Summary

Implement a rigorous test suite to achieve 90-100% code coverage for `ticker.R`, `indice.R`, `tickers.R`, and `utils.R` using `httptest2` for offline hermetic testing. The primary focus is testing API error branches, currency conversion, unexecuted lines in `indice.R`, partial failures in `Tickers$aggregate_data()`, and edge cases in utility functions.

## Technical Context

**Language/Version**: R  
**Primary Dependencies**: `R6`, `httr2`, `jsonlite`, `testthat`, `httptest2`  
**Storage**: N/A  
**Testing**: `testthat`, `httptest2`, `covr`  
**Target Platform**: CRAN  
**Project Type**: R Package (library)  
**Performance Goals**: Fast local test execution  
**Constraints**: 100% offline tests (Hermetic testing)  
**Scale/Scope**: Test additions for existing components

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **CRAN Submission Compliance**: Passed. Code uses `::` namespace spacing and avoids global state.
- **R6 Class Consistency**: Passed. Tests respect encapsulation.
- **Defensive Programming**: Passed. Tests explicitly verify error handling and graceful failures.
- **Strict Hermetic Testing**: Passed. All tests will use `httptest2::with_mock_dir()` and `without_internet()`.
- **Data Structure Consistency**: Passed. Tests verify `tibble` / `data.frame` return types.

## Project Structure

### Documentation (this feature)

```text
specs/001-coverage-hardening/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
tests/
└── testthat/
    ├── test-ticker.R
    ├── test-indice.R
    ├── test-tickers.R
    ├── test-utils.R
    └── samples/         # Mock data directory for httptest2
```

**Structure Decision**: Standard R package structure for tests.
