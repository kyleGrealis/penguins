# Penguin Species Predictor: Plumber API and Shiny App

This project demonstrates how to build a Plumber API in R to serve a machine learning model and then consume that API with a Shiny web application. 

The project is divided into three main components:

1.  **`analysis/`**: Contains an R script (`vetiver_model_creation.R`) that trains a random forest model using the `{tidymodels}` framework and saves the trained model artifact (`model.rds`) for use by the API.
2.  **`plumber_api/`**: Contains the Plumber API that exposes a pre-trained random forest model for predicting penguin species.
3.  **`shiny_app/`**: Contains the Shiny web application that allows users to input penguin measurements and get a species prediction from the API.

For a detailed walkthrough of the original project, you can follow along with this [video](https://www.youtube.com/watch?v=J0Th2QRZ7Rk).

<p align="center">
  <a href="http://www.youtube.com/watch?v=J0Th2QRZ7Rk">
    <img src="http://img.youtube.com/vi/J0Th2QRZ7Rk/0.jpg" alt="Integrating R with Plumber APIs">
  </a>
</p>

## Getting Started

The project's workflow is managed through npm scripts defined in `package.json`.

### 1. One-Time Setup (Model Generation)

Before running the API for the first time, you must generate the `model.rds` file.

```bash
# Run the setup script to create the model
npm run setup
```
This will execute the `analysis/vetiver_model_creation.R` script and place the `model.rds` file in the `plumber_api/` directory.

### 2. Running the API & App

For local development, you should run the API and the Shiny App in two separate terminals.

**Terminal 1: Run the API**
```bash
npm run api
```
The API will be available at `http://127.0.0.1:8000`. You can explore the interactive documentation via Swagger UI at `http://127.0.0.1:8000/__docs__/`.

**Terminal 2: Run the Shiny App**
```bash
npm run shiny
```
This will launch the Shiny application in your default web browser.

---