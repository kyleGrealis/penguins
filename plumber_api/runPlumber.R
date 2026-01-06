# this script will be used to run the API
library(plumber)
pr(here::here("plumber_api", "plumber.R")) |> 
  pr_run(port = 8000)
