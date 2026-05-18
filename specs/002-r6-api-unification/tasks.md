# Tasks: R6 Class Unification and API Consolidation

**Input**: Design documents from `/specs/002-r6-api-unification/`
**Prerequisites**: plan.md, spec.md

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Establish the foundational base class and consolidate utilities.

- [x] T001 [P] Consolidate `flatten_list` and `get_metric` into a single `flatten_list` function in `R/utils.R`.
- [x] T002 [P] Create `YahooFinanceBase` R6 class in `R/base.R` with centralized HTTP and `get_history` logic.

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Ensure tests cover the newly consolidated utility before migrating user stories.

- [x] T003 Update `tests/testthat/test-utils.R` to test the new `flatten_list` behavior.

## Phase 3: User Story 2 - Shared API Foundation (Priority: P1)

**Goal**: Establish a single source of truth for Yahoo Finance API requests to fix bugs and update logic in one place.

- [x] T004 [US2] Update `Ticker` class in `R/ticker.R` to inherit from `YahooFinanceBase` and remove duplicated `get_history` and HTTP boilerplate.
- [x] T005 [US2] Run tests in `tests/testthat/test-ticker.R` to verify `Ticker` functionality after inheritance.

## Phase 4: User Story 1 - Unified Symbol Naming (Priority: P1)

**Goal**: Provide a consistent API for both Tickers and Indices using `symbol`.

- [x] T006 [US1] Update `Index` class in `R/indice.R` to inherit from `YahooFinanceBase`.
- [x] T007 [US1] Implement Option B soft-deprecation in `Index$initialize` and `set_index` in `R/indice.R` to intercept `index` parameter, throw a lifecycle warning, and map to `symbol`.
- [x] T008 [US1] Update tests in `tests/testthat/test-index.R` to verify the warning is thrown when `index` is used, and verify it still functions correctly.

## Phase 5: User Story 3 - Unified History Retrieval (Priority: P2)

**Goal**: Ensure `get_history` behaves identically for both `Ticker` and `Index`, including date validation.

- [x] T009 [US3] Verify parameterized test coverage for `get_history` in `tests/testthat/test-index.R` and `tests/testthat/test-ticker.R`, adding new tests for invalid date strings to ensure it handles them identically.

## Phase 6: User Story 4 - Streamlined Utilities (Priority: P2)

**Goal**: Clean up internal data processing pipeline by removing redundant utilities.

- [x] T010 [US4] Remove `get_metric` calls from `R/ticker.R` and replace them with `flatten_list`.

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple components.

- [x] T011 [P] Ensure all internal method calls (`private$meta_info`, etc.) in `R/ticker.R` use the centralized HTTP logic via `YahooFinanceBase`.
- [x] T012 Run full test suite via `devtools::test()` to validate the refactor.
