# this script is going to create a shiny app that will communicate with
# the penguin plumber API that was created and being hosted on Posit Connect

# this will be a simple shiny app that will accept user input regarding the
# dimension specifics of a penguin and then send that data to the API to be
# evaluated by the model and return the predicted species of penguin

library(shiny)
library(bslib)
# load the jsonlite package to handle the incoming data
library(jsonlite)
# load the httr package to handle the API calls
library(httr)



adelie <- list(
  h4("Adelie", class = "center-text"),
  uiOutput("adelie_img"),
  span(textOutput("adelie"), class = "center-text")
)

chinstrap <- list(
  h4("Chinstrap", class = "center-text"),
  uiOutput("chinstrap_img"),
  span(textOutput("chinstrap"), class = "center-text")
)

gentoo <- list(
  h4("Gentoo", class = "center-text"),
  uiOutput("gentoo_img"),
  span(textOutput("gentoo"), class = "center-text")
)

# creating the ui ----
ui <- page_fixed(
  tags$head(
    tags$style(HTML("
      body {
        background-attachment: fixed;
        margin: auto;
        background-image: url('antarctica.jpg');
        background-repeat: no-repeat;
        background-size: cover;
        color: white;
      }
      .sidebar {
        display: flex;
        flex-direction: column;
        justify-content: space-between;
        background-color: #f7f7f7;
        border-color: gray;
        color: black;
      }
      .shiny-image-output {
        display: block;
        margin-left: auto;
        margin-right: auto;
        height: 300px;
        width: 100%; /* Use full width of the container */
        object-fit: cover; /* Prevents distortion */
        transition: opacity 0.5s ease-in-out; /* Smooth transition */
      }
      .center-text {
        text-align: center;
      }
    "))
  ),
  title = "Penguin Species Predictor",
  tags$head(tags$style(".title { font-weight: bold; }")),
  titlePanel(title = div("Penguin Species Predictor", class = "title")),
  
  sidebarLayout(
    
    sidebarPanel(
      numericInput("bill_length_mm", "Bill length (mm)", value = 46),
      numericInput("bill_depth_mm", "Bill depth (mm)", value = 16),
      numericInput("flipper_length_mm", "Flipper length (mm)", value = 185),
      numericInput("body_mass_g", "Body mass (g)", value = 5000),
      actionButton("submit", "What penguin did I find?"),
      tags$hr(style = "border-color: gray;"),
      actionButton("reset", "Reset"),
      class = "sidebar"
    ),
    
    mainPanel(
      h2("You are..."),
      p("an ornithologist studying the migratory patterns of the local penguins at the Palmer Station, Antarctica LTER (Long Term Ecological Research Network) on the Palmer archipelago. You are in the southwestern Antarctic when you encounter a colony of penguins and you want to know what type they are."),
      p("You've measured a penguin's bill length, bill depth, flipper length, and body mass. You can now enter these measurements into the app and it will predict the species of penguin you found."),
      
      uiOutput("predicted_species_header"),
      
      layout_column_wrap(
        width = "200px", height = "300px",
        adelie,
        chinstrap,
        gentoo
      )
    )
  )
)



# creating the server ----
server <- function(input, output, session) {
  
  # Reactive value to store the prediction probabilities.
  # NULL indicates no prediction has been made yet.
  penguin_prediction <- reactiveVal(NULL)
  
  # Reactive value to track if the submit button has been clicked
  submitClicked <- reactiveVal(FALSE)
  
  # Get prediction from API when submit button is clicked
  observeEvent(input$submit, {
    # Construct the request
    url <- "http://127.0.0.1:8000/predict"
    query <- list(
      bill_length_mm = input$bill_length_mm,
      bill_depth_mm = input$bill_depth_mm,
      flipper_length_mm = input$flipper_length_mm,
      body_mass_g = input$body_mass_g
    )
    
    # Make the API call
    response <- GET(url, query = query)
    result <- content(response, "parsed")
    
    # Extract and name the probabilities
    probabilities <- unlist(result)
    species <- c("Adelie", "Chinstrap", "Gentoo")
    names(probabilities) <- species
    
    # Update the reactive values
    penguin_prediction(probabilities)
    submitClicked(TRUE)
  })
  
  # show the "predicted probabilities" header when the submit button is clicked
  output$predicted_species_header <- renderUI({
    if (submitClicked()) {
      h3("Predicted Species")
    }
  })

  base <- 0.3
  
  # Render the images with opacity based on the prediction
  output$adelie_img <- renderUI({
    probs <- penguin_prediction()
    # Set opacity: 1 before prediction, or a value based on probability after
    opacity <- if (is.null(probs)) 1 else max(0.5, min(probs["Adelie"] + base, 1))
    tags$img(
      src = "adelie.jpg",
      style = paste0("opacity: ", opacity),
      class = "shiny-image-output"
    )
  })
  
  output$chinstrap_img <- renderUI({
    probs <- penguin_prediction()
    opacity <- if (is.null(probs)) 1 else max(0.5, min(probs["Chinstrap"] + base, 1))
    tags$img(
      src = "chinstrap.jpg",
      style = paste0("opacity: ", opacity),
      class = "shiny-image-output"
    )
  })
  
  output$gentoo_img <- renderUI({
    probs <- penguin_prediction()
    opacity <- if (is.null(probs)) 1 else max(0.5, min(probs["Gentoo"] + base, 1))
    tags$img(
      src = "gentoo.jpg",
      style = paste0("opacity: ", opacity),
      class = "shiny-image-output"
    )
  })
  
  # Render the text probabilities
  output$adelie <- renderText({
    probs <- penguin_prediction()
    if (is.null(probs)) return("")
    glue::glue('{round(probs["Adelie"]*100, 2)}%')
  })
  
  output$chinstrap <- renderText({
    probs <- penguin_prediction()
    if (is.null(probs)) return("")
    glue::glue('{round(probs["Chinstrap"]*100, 2)}%')
  })
  
  output$gentoo <- renderText({
    probs <- penguin_prediction()
    if (is.null(probs)) return("")
    glue::glue('{round(probs["Gentoo"]*100, 2)}%')
  })
  
  # Reset the inputs and outputs when the reset button is clicked
  observeEvent(input$reset, {
    updateNumericInput(session, "bill_length_mm", value = 46)
    updateNumericInput(session, "bill_depth_mm", value = 16)
    updateNumericInput(session, "flipper_length_mm", value = 185)
    updateNumericInput(session, "body_mass_g", value = 5000)
    
    # Reset the prediction and hide the header
    penguin_prediction(NULL)
    submitClicked(FALSE)
  })
}

shinyApp(ui = ui, server = server)
