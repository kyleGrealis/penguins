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
library(glue)

# for model
library(parsnip)
library(ranger)

# Goal ----
model <- readRDS("../model.rds")

# random forest model
# predict(
#   model, 
#   newdata = jsonlite::read_json("penguins.json", simplifyVector = TRUE), 
#   type = "prob"
# )

# Write the API ----
#* @apiTitle Penguin Plumber API
#* @apiDescription API to the penguin random forest model.

#* Health check -- is the API running?
#* @get /health-check
status <- function() {
    list(
      msg = glue::glue("If you're reading this, the API is working!"),
      time = Sys.time()
    )
}

#* Predict penguin species
#* @post /predict
function(req, res) {
    predict(model, new_data = as.data.frame(req$body), type = "prob")
}


# Programmatically alter your API
#* @plumber
function(pr) {
    pr |> 
      # Overwrite the default serializer to return unboxed JSON
      # pr_set_serializer(serializer_unboxed_json())
      # add API specification file; customize the look of the API
      pr_set_api_spec(yaml::read_yaml("../penguin-api.yaml"))
}
