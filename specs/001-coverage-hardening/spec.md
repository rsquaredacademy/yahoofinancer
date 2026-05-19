# Feature Specification: Test Coverage Hardening

**Feature Branch**: `refactor/hardening-and-coverage` (Current Branch)
**Created**: 2026-05-15
**Status**: Draft
**Input**: User description: "Use the current branch for this specification. Look at the coverage.html file in the root. Implement a rigorous test suite to achieve 90-100% code coverage for ticker.R, indice.R, tickers.R, and utils.R as a pre-refactor hardening phase, specifically targeting missed logic in ticker.R regarding API error branches and currency conversion along with the currently unexecuted lines in indice.R. Utilize testthat::with_mocked_bindings for all httr::GET and curl::has_internet calls to ensure 100% offline execution while maintaining the current self$index naming convention in indice.R for these tests, as standardization to self$symbol will be handled in a subsequent refactor spec. Furthermore, validate the robustness of Tickers$aggregate_data() by mocking scenarios where a subset of symbols fails to ensure the tryCatch logic handles partial data correctly, and exercise validate(), flatten_list(), and get_metric() with NULL, empty, and malformed inputs to cover all utility edge-cases."

## Clarifications

### Session 2026-05-15
- Q: Which mocking framework should be used? → A: Use `httptest2` (Project Standard for `httr2`)
- Q: What happens when an API responds with unexpected HTTP status codes (e.g., 503, 403)? → A: Throw an error (Default `httr2` behavior)
- Q: How does the system handle totally malformed JSON responses in the utility functions? → A: Throw an error during parsing

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Ticker Offline Robustness (Priority: P1)

As a developer maintaining the library, I need confidence that changes to `ticker.R` won't break existing API parsing logic or error handling, so that I can refactor safely.

**Why this priority**: Core functionality relies on `ticker.R`, and ensuring its correctness across edge cases is essential before refactoring.

**Independent Test**: Can be tested by running the test suite offline and verifying that test coverage for `ticker.R` meets or exceeds 90%, with specific tests covering API errors and currency conversions.

**Acceptance Scenarios**:
1. **Given** an offline environment with mocked API error responses, **When** a Ticker method is called, **Then** it correctly triggers the expected error branch.
2. **Given** mocked data with foreign currency formats, **When** currency conversion logic is executed, **Then** it correctly processes the data.

---

### User Story 2 - Indice and Utility Edge Cases (Priority: P1)

As a developer, I need to ensure `indice.R` and `utils.R` handle malformed and unexpected inputs gracefully, so that the library doesn't crash unexpectedly during data ingestion.

**Why this priority**: Unexecuted lines in `indice.R` and unhandled utility edge cases are prime spots for silent failures during refactoring.

**Independent Test**: Run unit tests targeting `validate()`, `flatten_list()`, `get_metric()`, and all unexecuted lines in `indice.R`.

**Acceptance Scenarios**:
1. **Given** NULL, empty, or malformed inputs, **When** `validate()`, `flatten_list()`, or `get_metric()` are called, **Then** they process the inputs gracefully without crashing.
2. **Given** a mock setup where `self$index` is used, **When** indice methods are executed, **Then** the tests pass and cover previously unexecuted paths.

---

### User Story 3 - Tickers Partial Failure Handling (Priority: P2)

As a library user, I need to reliably retrieve aggregate data for multiple tickers even if some symbols fail, so that my broader data analysis is not interrupted by a single bad ticker.

**Why this priority**: Users frequently query multiple tickers; partial failures are common and must be handled by `Tickers$aggregate_data()`.

**Independent Test**: Mock a scenario where some symbols succeed and others fail during an aggregate request, and verify the resulting dataset contains data for the successful symbols.

**Acceptance Scenarios**:
1. **Given** a list of tickers where one ticker is mocked to fail, **When** `Tickers$aggregate_data()` is called, **Then** the `tryCatch` logic successfully handles the failure and returns valid data for the successful tickers.

### Edge Cases

- The system must throw an error when the API responds with unexpected HTTP status codes (e.g., 503, 403), matching the default `httr2` behavior.
- Totally malformed JSON responses processed by utility functions must result in a parsing error being thrown.
- If *all* requested symbols fail during `Tickers$aggregate_data()`, the function must return an empty data frame/tibble.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The test suite MUST achieve 90-100% code coverage for `ticker.R`, `indice.R`, `tickers.R`, and `utils.R`.
- **FR-002**: All network requests MUST be mocked using `httptest2` (and `httptest2::without_internet()`) to ensure tests run offline.
- **FR-003**: Tests for `indice.R` MUST temporarily maintain the `self$index` naming convention without attempting to standardize it to `self$symbol`.
- **FR-004**: The test suite MUST include test cases for API error branches and currency conversion logic within `ticker.R`.
- **FR-005**: The test suite MUST include test cases for previously unexecuted logic in `indice.R`.
- **FR-006**: The test suite MUST include tests for `Tickers$aggregate_data()` that simulate partial failure of some symbols.
- **FR-007**: The test suite MUST include tests for `validate()`, `flatten_list()`, and `get_metric()` using NULL, empty, and malformed inputs.

## Assumptions

- We are operating on an already existing test suite foundation.
- The `coverage.html` file in the root accurately reflects the current unexecuted lines.
- No new features or public APIs are being added; this is strictly an addition of tests.

## Success Criteria *(mandatory)*

- Code coverage metrics show 90% or higher for `ticker.R`, `indice.R`, `tickers.R`, and `utils.R`.
- The test suite executes completely without an active internet connection.
- `Tickers$aggregate_data()` is verified to return partial data when some, but not all, symbols fail.
- Utility functions are verified to not crash when provided with NULL, empty, or malformed inputs. are verified to not crash when provided with NULL, empty, or malformed inputs.