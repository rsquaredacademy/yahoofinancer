# Tasks: Test Coverage Hardening

**Input**: Design documents from `specs/001-coverage-hardening/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/api_contracts.md

**Tests**: Tests are explicitly requested to achieve code coverage goals.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [ ] T001 Update `DESCRIPTION` to include `httptest2` in Suggests and ensure `httr` is in Imports
- [ ] T002 Initialize `httptest2` and configure `tests/testthat/setup.R` with `httptest2::without_internet()`
- [ ] T003 [P] Configure `tests/testthat.R` to support the new test environment

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure for mocking and utility testing

- [ ] T004 Create `tests/testthat/helper-mocks.R` for shared mocking functions (e.g., mocking `curl::has_internet`)
- [ ] T005 [P] Setup `tests/testthat/samples/` directory structure for new mock recordings

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Ticker Offline Robustness (Priority: P1) 🎯 MVP

**Goal**: Achieve 90-100% coverage for `ticker.R`, specifically targeting API error branches and currency conversion.

**Independent Test**: `devtools::test(filter = "ticker")` and verify `R/ticker.R` coverage exceeds 90%.

### Implementation for User Story 1

- [ ] T006 [P] [US1] Create mock responses for Ticker API errors (404/500) in `tests/testthat/samples/ticker_error/`
- [ ] T007 [P] [US1] Create mock responses for currency data in `tests/testthat/samples/ticker_currency/`
- [ ] T008 [US1] Implement tests for `Ticker$get_history()` error branches in `tests/testthat/test-ticker.R`
- [ ] T009 [US1] Implement tests for `Ticker$valuation_measures()` empty result handling in `tests/testthat/test-ticker.R`
- [ ] T010 [US1] Implement tests for `Ticker$recommendations()` empty symbols handling in `tests/testthat/test-ticker.R`
- [ ] T011 [US1] Implement tests for `Ticker$technical_insights()` error handling in `tests/testthat/test-ticker.R`
- [ ] T012 [US1] Implement tests for `currency_converter()` in `tests/testthat/test-currency.R`

**Checkpoint**: User Story 1 (Ticker) should have 90%+ coverage and pass offline.

---

## Phase 4: User Story 2 - Indice and Utility Edge Cases (Priority: P1)

**Goal**: Achieve 90-100% coverage for `indice.R` and `utils.R` by exercising all logic paths with edge-case inputs.

**Independent Test**: `devtools::test(filter = "index|utils")` and verify target file coverage.

### Implementation for User Story 2

- [ ] T013 [P] [US2] Create mock responses for Index API errors in `tests/testthat/samples/index_error/`
- [ ] T014 [US2] Implement tests for `Index$get_history()` unexecuted error lines in `tests/testthat/test-index.R` (maintaining `self$index`)
- [ ] T015 [P] [US2] Implement tests for `validate()` with NULL, empty, and malformed inputs in `tests/testthat/test-utils.R`
- [ ] T016 [P] [US2] Implement tests for `flatten_list()` with NULL and empty list inputs in `tests/testthat/test-utils.R`
- [ ] T017 [P] [US2] Implement tests for `get_metric()` with missing metrics and NULL data in `tests/testthat/test-utils.R`

**Checkpoint**: Indice and Utility functions should be fully covered and robust against bad inputs.

---

## Phase 5: User Story 3 - Tickers Partial Failure Handling (Priority: P2)

**Goal**: Validate that `Tickers$aggregate_data()` correctly handles scenarios where some symbols fail.

**Independent Test**: `devtools::test(filter = "tickers")`

### Implementation for User Story 3

- [ ] T018 [US3] Implement tests for `Tickers$aggregate_data()` mocking mixed success/failure symbols in `tests/testthat/test-tickers.R`
- [ ] T019 [US3] Implement tests for `Tickers` active properties with partial symbol failures in `tests/testthat/test-tickers.R`
- [ ] T020 [US3] Implement tests for `Tickers` aggregation when ALL symbols fail (returning NULL/empty) in `tests/testthat/test-tickers.R`

**Checkpoint**: Tickers aggregation logic is verified to be resilient to partial API failures.

---

## Phase N: Polish & Cross-Cutting Concerns

**Purpose**: Final validation and documentation

- [ ] T021 [P] Update `audit.md` with new test coverage statistics
- [ ] T022 Code cleanup in test files (standardize mocking patterns)
- [ ] T023 Run `quickstart.md` validation steps to ensure reproducibility
- [ ] T024 Final CRAN-compliance check (no global state changes in tests)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately.
- **Foundational (Phase 2)**: Depends on T001-T003.
- **User Stories (Phase 3+)**: All depend on Phase 2 completion.
  - Phase 3, 4, and 5 can proceed in parallel once foundational helpers are ready.

### Parallel Examples: Setup & Utilities

```bash
# Setup tasks that can run in parallel:
Task: "Configure tests/testthat.R to support the new test environment" (T003)
Task: "Setup tests/testthat/samples/ directory structure" (T005)

# Independent utility tests (User Story 2):
Task: "Implement tests for validate() with NULL/malformed inputs" (T015)
Task: "Implement tests for flatten_list() with NULL/empty list inputs" (T016)
Task: "Implement tests for get_metric() with missing metrics" (T017)
```

---

## Implementation Strategy

### MVP First (User Stories 1 & 2)

1. Complete Phase 1 and 2.
2. Focus on User Story 1 (Ticker) as it is the core of the library.
3. Simultaneously work on User Story 2 (Utilities) as they are independent.
4. **STOP and VALIDATE**: Verify coverage for `ticker.R`, `indice.R`, and `utils.R`.

### Incremental Delivery

1. Foundation ready.
2. Hardened Ticker + Utilities → Verified baseline.
3. Add Indice hardening.
4. Add Tickers resilience hardening.
5. Final Polish.
