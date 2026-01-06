# Penguin Finder Shiny App

This Shiny application provides a web interface to predict penguin species using a Plumber API. It now features improved image rendering using opacity to better visualize prediction probabilities.

## How to Run

1.  **Start the API:** Before running this app, ensure the Plumber API from the `../plumber_api` directory is running. You can start it using `npm run api` from the project root.

2.  **Run the App:** With the API running, you can launch this Shiny app from the project root:
    ```bash
    npm run shiny
    ```

The application will open in your web browser, allowing you to input penguin measurements and receive a prediction from the API.
