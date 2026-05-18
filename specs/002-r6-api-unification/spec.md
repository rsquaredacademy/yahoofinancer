# Feature Specification: R6 Class Unification and API Consolidation

**Feature Branch**: `current`  
**Created**: 2026-05-18  
**Status**: Draft  
**Input**: User description: "Based on the structural boundaries in audit.md, analyze the entire codebase to map out a complete refactoring specification that addresses all code redundancy, duplication, and naming inconsistencies. Specifically, your specification must plan the migration of the Index class from using self$index and index parameters over to self$symbol and symbol to match the Ticker class. Additionally, map out how to eliminate the duplicated HTTP boilerplate and get_history logic between Ticker and Index by consolidating them into a unified base R6 class or a shared API wrapper. Finally, detail the consolidation of the competing utility functions flatten_list and get_metric in utils.R, ensuring that the new test suite targets these streamlined structures while updating Issue #24 using the gh CLI as each task is defined."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Unified Symbol Naming (Priority: P1)

As a user of the package, I want a consistent API for both Tickers and Indices so that I don't have to remember different parameter names (like `index` vs `symbol`) depending on which object I am using.

**Why this priority**: It removes cognitive load for users and aligns with how Yahoo Finance treats all entities (as symbols).

**Independent Test**: Can be tested by instantiating an `Index` object using the `symbol` argument and checking `self$symbol` instead of `self$index`.

**Acceptance Scenarios**:

1. **Given** a user wants to track a market index, **When** they call `Index$new(symbol = '^NSEI')`, **Then** the object should store the value in `self$symbol`.
2. **Given** an existing `Index` object, **When** they call `set_symbol('^NDX')`, **Then** the object should update the symbol correctly.

---

### User Story 2 - Shared API Foundation (Priority: P1)

As a maintainer, I want a single source of truth for Yahoo Finance API requests so that I can fix bugs or update API logic in one place rather than multiple files.

**Why this priority**: Critical for long-term maintainability and reducing technical debt identified in the audit.

**Independent Test**: Verify that `Ticker` and `Index` both inherit from a base class or use a shared internal function for GET requests and error handling.

**Acceptance Scenarios**:

1. **Given** an API request failure (e.g., 404), **When** either `Ticker` or `Index` methods are called, **Then** they should return the same standardized error message and handle the failure gracefully.
2. **Given** no internet connection, **When** any API-dependent method is called, **Then** it should consistently inform the user and return `NULL` invisibly.

---

### User Story 3 - Unified History Retrieval (Priority: P2)

As a developer, I want `get_history` to behave identically for both Tickers and Indices, including date validation and result formatting.

**Why this priority**: `get_history` is a core feature; its current fragmentation leads to subtle bugs (like missing date validation in `Index`).

**Independent Test**: Run a parameterized test suite against both `Ticker` and `Index` for various date ranges and intervals.

**Acceptance Scenarios**:

1. **Given** an invalid date string in `get_history`, **When** called on an `Index` object, **Then** it should throw the same helpful error as `Ticker`.
2. **Given** a valid request, **When** `get_history` is called, **Then** the returned `data.frame` structure should be identical for both classes.

---

### User Story 4 - Streamlined Utilities (Priority: P2)

As a developer, I want a single, robust utility for data cleaning and flattening so that the codebase is cleaner and easier to test.

**Why this priority**: Eliminates redundant functions (`flatten_list` and `get_metric`) and simplifies the internal data processing pipeline.

**Independent Test**: Unit tests for the new consolidated utility handling vectors with `NULL` or missing values.

**Acceptance Scenarios**:

1. **Given** a list with `NULL` elements, **When** the new utility is called, **Then** it should return a vector with `NA` in place of `NULL`.

---

### Edge Cases

- **Invalid Symbols**: How does the system handle symbols that pass validation but fail during data retrieval?
- **Missing Data Fields**: What happens if Yahoo Finance returns a response missing specific indicators (e.g., no `adj_close` for certain intervals)?
- **Rate Limiting**: Standardized behavior when hitting API rate limits.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide a base R6 class or shared internal module for all Yahoo Finance API interactions.
- **FR-002**: `Index` class MUST use `symbol` as its primary identifier and parameter name, deprecating `index`.
- **FR-003**: `get_history` logic MUST be consolidated to use a single implementation for both `Ticker` and `Index`.
- **FR-004**: System MUST use `lubridate` for consistent date parsing and validation across all classes.
- **FR-005**: `flatten_list` and `get_metric` MUST be merged into a single utility function in `utils.R`.
- **FR-006**: All public methods MUST consistently check for internet connectivity before attempting API calls.
- **FR-007**: API response parsing MUST be centralized to handle HTTP errors and JSON extraction uniformly.

### Key Entities

- **YahooFinanceBase**: Internal base class or module providing shared connectivity and parsing logic.
- **Ticker**: Inherits from `YahooFinanceBase`, focused on equity-specific metrics.
- **Index**: Inherits from `YahooFinanceBase`, migrated to use `symbol` terminology.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of existing and new tests pass using the unified architecture.
- **SC-002**: Elimination of at least 150 lines of duplicated code across `ticker.R` and `indice.R`.
- **SC-003**: All public API parameters for identifiers are named `symbol`.
- **SC-004**: No direct `httr::GET` or `jsonlite::fromJSON` calls exist outside the consolidated API layer.

## Assumptions

- **Backward Compatibility**: While we are deprecating `index`, we will focus on the new `symbol` standard; the user did not explicitly ask for a legacy support period, but we will assume internal consistency is preferred.
- **Testing Environment**: Tests will continue to use mocked responses where possible to ensure stability.
- **Dependencies**: Lubridate and HTTR will remain the primary dependencies for date and network handling.
