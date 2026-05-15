# Research: Test Coverage Hardening

## Decision: Mocking Framework
- **Decision**: Use `httptest2` and `testthat` as requested, but recognize that `httptest2` is optimized for `httr2`.
- **Rationale**: The Constitution and Feature Spec both mandate `httptest2`. While the current code uses `httr`, I will use `httptest2::with_mock_dir()` to record/replay and `httptest2::without_internet()` to enforce offline status. If `httr` requests bypass `httptest2::without_internet()`, I will use `testthat::with_mocked_bindings` as a fallback as suggested in the spec description.
- **Alternatives considered**: `httptest` (rejected because it's against the new Constitution mandate).

## Decision: Targeted Coverage Areas
- **Decision**: Focus on the following specific branches:
    - **API Errors**: Return 404/500 and verify `warning()` or `message()` is called and `NULL`/empty DF is returned.
    - **Offline**: Mock `curl::has_internet()` to return `FALSE` and verify graceful failure.
    - **Malformed Data**: Provide JSON with missing fields (e.g., no `timestamp`) to trigger edge case returns.
    - **Partial Success**: In `Tickers$aggregate_data()`, mock a scenario where one symbol succeeds and another throws an error.
    - **Utility Edge Cases**: Pass `NULL`, `list()`, and `NA` to `validate()`, `flatten_list()`, and `get_metric()`.
- **Rationale**: These are the specific areas identified in the Feature Spec and through manual inspection of the source code.

## Decision: Currency Conversion
- **Decision**: Test `currency_converter()` in `others.R` as the "currency conversion" logic mentioned in the spec.
- **Rationale**: `ticker.R` only has a passive `currency` field. The functional logic resides in `others.R`.

## Technical Unknowns Resolved
- **httr vs httr2**: Code is `httr`, but target is `httr2`. Hardening will use `httptest2` to align with future state.
- **self$index**: Confirmed `indice.R` uses `self$index`. Tests will respect this.
- **Missed logic**: Identified specific `if` branches in `ticker.R` and `indice.R` that need mocking.
