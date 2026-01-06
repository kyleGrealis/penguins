#
# This is a Plumber API. You can run the API by clicking
# the 'Run API' button above.
#
# Find out more about building APIs with Plumber here:
#
#    https://www.rplumber.io/
#

# for api
library(plumber)
library(yaml)

# for model
library(parsnip)
library(ranger)

# Goal ----
model <- readRDS(here::here("plumber_api", "model.rds"))


# Write the API ----
#* @apiTitle Penguin Plumber API
#* @apiDescription API to the penguin random forest model.


# this part can be removed since the API is not public and is only for internal use
#* Health check -- is the API running?
#* @get /health-check
status <- function() {
    list(
      msg = "If you're reading this, the API is working!",
      time = Sys.time()
    )
}


#* Predict penguin species
#* @get /predict
function(bill_length_mm, bill_depth_mm, flipper_length_mm, body_mass_g) {
  new_data <- data.frame(
    bill_length_mm = as.numeric(bill_length_mm),
    bill_depth_mm = as.numeric(bill_depth_mm),
    flipper_length_mm = as.numeric(flipper_length_mm),
    body_mass_g = as.numeric(body_mass_g)
  )
  predict(model, new_data = new_data, type = "prob")
}


# Programmatically alter your API
#* @plumber
function(pr) {
  pr |> 
    # add API specification file; customize the look of the API
    # provides the ability to input/modify prediction data within the API
    pr_set_api_spec(yaml::read_yaml("penguin-api.yaml"))
}
