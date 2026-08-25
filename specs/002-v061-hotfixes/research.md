# Research & API Discovery: v0.6.1 Hotfixes

**Date**: 2026-08-24 | **Feature**: v0.6.1 Hotfixes  

---

## 1. Yahoo Finance `fundamentals-timeseries` Endpoint

### 1.1 Endpoint Overview
- **URL**: `https://query2.finance.yahoo.com/ws/fundamentals-timeseries/v1/finance/timeseries/{symbol}`
- **HTTP Method**: `GET`
- **Authentication**: Gated behind Yahoo's crumb & session cookie in certain regions or under high request frequencies.

### 1.2 Query Parameters
| Parameter | Type | Description | Example |
|---|---|---|---|
| `type` | string | Comma-separated list of metric type codes | `annualTotalRevenue,annualOperatingIncome` |
| `period1` | integer | Unix timestamp for range start (optional) | `1577836800` |
| `period2` | integer | Unix timestamp for range end (optional) | `1735689600` |
| `merge` | boolean | Whether to merge series across definitions | `false` |
| `padTimeSeries`| boolean | Pad missing periods | `true` |

### 1.3 Type Code Registry for Financial Statements

#### A. Income Statement (`frequency = "annual"` vs `"quarterly"`)
Prefix: `annual` or `quarterly`
- `TotalRevenue`, `OperatingRevenue`, `CostOfRevenue`, `GrossProfit`
- `OperatingExpense`, `OperatingIncome`, `NetNonOperatingInterestIncomeExpense`
- `OtherIncomeExpense`, `PretaxIncome`, `TaxProvision`, `NetIncomeContinuousOperations`
- `NetIncome`, `BasicEPS`, `DilutedEPS`, `BasicAverageShares`, `DilutedAverageShares`
- `EBITDA`, `EBIT`, `NormalizedEBITDA`, `NormalizedIncome`

#### B. Balance Sheet (`frequency = "annual"` vs `"quarterly"`)
Prefix: `annual` or `quarterly`
- `TotalAssets`, `CurrentAssets`, `CashAndCashEquivalents`, `OtherShortTermInvestments`, `Receivables`
- `Inventory`, `NonCurrentAssets`, `NetPPE`, `GoodwillAndOtherIntangibleAssets`
- `TotalLiabilitiesNetMinorityInterest`, `CurrentLiabilities`, `PayablesAndAccruedExpenses`, `CurrentDebt`
- `NonCurrentLiabilitiesTotal`, `LongTermDebt`, `TotalStockholderEquity`, `CommonStock`, `RetainedEarnings`
- `WorkingCapital`, `InvestedCapital`, `NetDebt`, `TotalDebt`

#### C. Cash Flow Statement (`frequency = "annual"` vs `"quarterly"`)
Prefix: `annual` or `quarterly`
- `OperatingCashFlow`, `CashFlowFromContinuingOperatingActivities`, `NetIncomeFromContinuingOperations`
- `DepreciationAndAmortization`, `ChangeInWorkingCapital`, `ChangeInReceivables`, `ChangeInInventory`
- `InvestingCashFlow`, `CashFlowFromContinuingInvestingActivities`, `CapitalExpenditure`, `NetPPEPurchaseAndSale`
- `FinancingCashFlow`, `CashFlowFromContinuingFinancingActivities`, `CommonStockIssuancePayments`, `CashDividendsPaid`
- `FreeCashFlow`, `EndCashPosition`, `BeginningCashPosition`

### 1.4 Raw JSON Structure vs Tidy Target Structure

#### Raw JSON response:
```json
{
  "timeseries": {
    "result": [
      {
        "meta": { "symbol": ["AAPL"], "type": ["annualTotalRevenue"] },
        "annualTotalRevenue": [
          { "asOfDate": "2021-09-25", "periodType": "12M", "reportedValue": { "raw": 365817000000 } },
          { "asOfDate": "2022-09-24", "periodType": "12M", "reportedValue": { "raw": 394328000000 } },
          { "asOfDate": "2023-09-30", "periodType": "12M", "reportedValue": { "raw": 383285000000 } }
        ]
      }
    ],
    "error": null
  }
}
```

#### Tidy Tibble Output Target:
```
# A tibble: 3 × 6
  date       period_type total_revenue cost_of_revenue gross_profit operating_income
  <date>     <chr>               <dbl>           <dbl>        <dbl>            <dbl>
1 2021-09-25 12M          365817000000    212981000000 152836000000     108949000000
2 2022-09-24 12M          394328000000    223546000000 170782000000     119437000000
3 2023-09-30 12M          383285000000    214137000000 169148000000     114301000000
```

---

## 2. HTTP Helper Extraction (`api_request()`)

### 2.1 Current Defect Analysis
In `R/others.R` and `R/validate.R`, HTTP requests are constructed manually:
- Uses `cat()` for errors with typo `"Mesage:"`.
- Inspects `$quoteSummary$error` even for `$chart` endpoints.
- Inconsistent retry policies.

### 2.2 Shared `api_request()` Design
```r
api_request <- function(url, query = list(), user_agent = NULL) {
  # 1. Default user agent
  # 2. Build httr2 request
  # 3. Apply timeout (15s), req_retry(max_tries = 4, backoff = ~ 2^i)
  # 4. Perform req_perform() wrapped in tryCatch
  # 5. Extract JSON and parse structured errors across chart, quoteSummary, timeseries
  # 6. Warn with symbol/endpoint details and return NULL on failure
}
```

---

## 3. Test Fixture Naming & CRAN Path Limits

`httptest2` records fixture files mirroring URL paths. Under `setup-httptest2.R`, URL redactors shorten path components to ensure all tarball files stay < 100 characters.

**Redaction mapping to add in `setup-httptest2.R`**:
- `ws/fundamentals-timeseries/v1/finance/timeseries` → `fts`
- `query2.finance.yahoo.com` → `q2`
