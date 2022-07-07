# install and load libraries
install.packages('httr2')
library(httr2)
library(jsonlite)
library(magrittr)

# request
url <- 'https://query1.finance.yahoo.com/v8/finance/chart/INFY.NS?region=US&lang=en-US&includePrePost=false&interval=2m&useYfid=true&range=1d&corsDomain=finance.yahoo.com&.tsrc=finance'
req <- request(url)
req

# dry run
req %>% req_dry_run()

# fetch response
resp <- req %>% req_perform()
resp

# raw response
resp %>% resp_raw()

# response status
resp %>% resp_status()
resp %>% resp_status_desc()

# headers
resp %>% resp_headers()

# extract
data <-
  resp %>%
  resp_body_json() %>%
  use_series(chart) %>%
  use_series(result) %>%
  extract2(1) %>%
  use_series(meta) %>%
  use_series(regularMarketPrice)
