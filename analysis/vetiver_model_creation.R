# Palmer Penguins modeling---
# Use the Palmer Penguins dataset to predict species

# Follow along using this: https://www.youtube.com/watch?v=J0Th2QRZ7Rk&t=199s

# Load libraries
suppressPackageStartupMessages({
  library(tidyverse)
  library(tidymodels)
  library(parsnip)
  library(vetiver)
  library(here)
})

# Modify penguins dataset
penguins_filtered <- penguins |> 
  drop_na(ends_with("mm")) |> 
  select(species, ends_with("mm"), body_mass_g)

# Model fit
# You can  use a tidymodels workflow or model types to create a vetiver_model() below. 
# Here I am creating a tidymodels workflow for the penguin predictor. 
# To see other supported models, see: https://vetiver.posit.co/get-started/#installation

# An alternate & simpler model that will also work is:
# ranger::ranger(species ~ ., data = penguins_filtered)

penguin_spec <- rand_forest() |> 
  set_engine('ranger') |> 
  set_mode('classification')

penguins_wf <- workflow() |> 
  add_formula(species~.) |> 
  add_model(penguin_spec) 

penguins_fit <- penguins_wf |> 
  fit(penguins_filtered)

# description <- 'Using vetiver to create a penguins model'
# v <- vetiver_model(penguins_fit, 'penguin-random-forest', description=description)
# v

# Extract the final fitted model from the workflow
final_fit <- extract_fit_parsnip(penguins_fit)

# Save the fitted model object that the Plumber API will load
saveRDS(final_fit, here::here("plumber_api", "model.rds"))

message('Penguins `model.rds` file created at: `./plumber_api/model.rds`')
 
