# this script will be used to run the API
library(plumber)
pr("R/plumber.R") |> 
  pr_run(port = 8000)
