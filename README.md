# Learning `plumber` and APIs

## Getting some help from the Palmer Penguins

This project will use the {palmerpenguins} dataset to predict the species of penguins. The {parsnip} package will be used to fit the random forest model. The purpose is not to demostrate how to create the best model, but to show how to save the model and use it in another project. In our case, the model object will be saved as an rds file and then used within another script to create a {plumber} API. 

The final goal of the project will be to create a {shiny} app that will allow the user to input the penguin's measurements and predict the species.
