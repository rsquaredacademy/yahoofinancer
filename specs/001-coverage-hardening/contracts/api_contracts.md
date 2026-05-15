# API Contracts: Mocking Schemas

This document defines the expected JSON structures for mocked Yahoo Finance API responses used in the test suite.

## Chart API (`v8/finance/chart/`)

### Success Response
```json
{
  "chart": {
    "result": [{
      "meta": { "currency": "USD", "symbol": "AAPL" },
      "timestamp": [1625059200],
      "indicators": {
        "quote": [{ "open": [135.0], "close": [136.0] }],
        "adjclose": [{ "adjclose": [135.5] }]
      }
    }]
  }
}
```

### Error Response (404/Invalid Symbol)
```json
{
  "chart": {
    "error": {
      "code": "Not Found",
      "description": "No data found for symbol XYZ"
    }
  }
}
```

## Fundamentals API (`ws/fundamentals-timeseries/v1/finance/timeseries/`)

### Success Response
```json
{
  "timeseries": {
    "result": [
      {
        "timestamp": [1625059200],
        "quarterlyMarketCap": [{ "reportedValue": { "raw": 2000000000000 } }]
      }
    ]
  }
}
```

## Recommendations API (`v6/finance/recommendationsbysymbol/`)

### Success Response
```json
{
  "finance": {
    "result": [{
      "recommendedSymbols": [
        { "symbol": "MSFT", "score": 0.95 }
      ]
    }]
  }
}
```

## Validation API (`v6/finance/quote/validate`)

### Valid Symbol
```json
{
  "symbolsValidation": {
    "result": [[{ "valid": true }]]
  }
}
```
