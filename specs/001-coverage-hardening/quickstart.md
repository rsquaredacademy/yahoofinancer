# Quickstart: Testing Coverage Hardening

## Running the Tests
To run the full test suite completely offline, ensuring hermetic testing constraints are met:

```R
# In the R console
devtools::test()
```

This will automatically invoke `httptest2::without_internet()` as configured in the tests.

## Checking Coverage
To verify that the target of 90-100% coverage is met:

```R
# In the R console
covr::package_coverage()
covr::report()
```
