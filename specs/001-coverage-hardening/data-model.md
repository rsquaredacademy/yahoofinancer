# Data Model / Testing Strategy: Coverage Hardening

## Entities to Test
1. **Ticker (`R/ticker.R`)**
   - Focus: API error branches (e.g., 404, 503, 403).
   - Focus: Currency conversion logic (foreign formats).
   - State: Mocked network responses.

2. **Indice (`R/indice.R`)**
   - Focus: Unexecuted lines identified in `coverage.html`.
   - Constraints: Maintain `self$index` naming convention during these tests.

3. **Tickers (`R/tickers.R`)**
   - Focus: `Tickers$aggregate_data()`.
   - Scenarios: Partial failure of some symbols in the list.

4. **Utils (`R/utils.R`)**
   - Functions: `validate()`, `flatten_list()`, `get_metric()`.
   - Scenarios: NULL, empty, and malformed inputs.
