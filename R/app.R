# this script is going to create a shiny app that will communicate with
# the penguin plumber API that was created and being hosted on Posit Connect

# this will be a simple shiny app that will accept user input regarding the
# dimension specifics of a penguin and then send that data to the API to be
# evaluated by the model and return the predicted species of penguin

library(shiny)
# load the jsonlite package to handle the incoming data
library(jsonlite)
# load the httr package to handle the API calls
library(httr)

ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      .shiny-image-output {
        display: block;
        margin: auto;
      }
      .center-text {
        text-align: center;
      }
    "))
  ),
  titlePanel("Penguin Species Predictor"),
  sidebarLayout(
    sidebarPanel(
      numericInput("bill_length_mm", "Bill length (mm)", value = 46.8),
      numericInput("bill_depth_mm", "Bill depth (mm)", value = 16.1),
      numericInput("flipper_length_mm", "Flipper length (mm)", value = 215),
      numericInput("body_mass_g", "Body mass (g)", value = 5500),
      actionButton("submit", "What penguin did I find?"),
      actionButton("reset", "Reset")
    ),
    mainPanel(
      h3("Predicted species:"),
      fluidRow(
        column(
          4,
          h4("Adelie", class = "center-text"),
          uiOutput("adelie_img"),
          span(textOutput("adelie"), class = "center-text")
        ),
        column(
          4,
          h4("Chinstrap", class = "center-text"),
          uiOutput("chinstrap_img"),
          span(textOutput("chinstrap"), class = "center-text")
        ),
        column(
          4,
          h4("Gentoo", class = "center-text"),
          uiOutput("gentoo_img"),
          span(textOutput("gentoo"), class = "center-text")
        )
      )
    )
  )
)

server <- function(input, output, session) {
  
  # Initialize images with equal sizes
  output$adelie_img <- renderUI({
    tags$img(src = "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e3/Hope_Bay-2016-Trinity_Peninsula%E2%80%93Ad%C3%A9lie_penguin_%28Pygoscelis_adeliae%29_04.jpg/600px-Hope_Bay-2016-Trinity_Peninsula%E2%80%93Ad%C3%A9lie_penguin_%28Pygoscelis_adeliae%29_04.jpg", width = "100%", height = "200px", class = "shiny-image-output")
  })
  output$chinstrap_img <- renderUI({
    tags$img(src = "https://upload.wikimedia.org/wikipedia/commons/thumb/0/08/South_Shetland-2016-Deception_Island%E2%80%93Chinstrap_penguin_%28Pygoscelis_antarctica%29_04.jpg/330px-South_Shetland-2016-Deception_Island%E2%80%93Chinstrap_penguin_%28Pygoscelis_antarctica%29_04.jpg", width = "100%", height = "200px", class = "shiny-image-output")
  })
  output$gentoo_img <- renderUI({
    tags$img(src = "https://upload.wikimedia.org/wikipedia/commons/e/eb/Gentoo_penguin.jpg", width = "100%", height = "200px", class = "shiny-image-output")
  })
  
  # Define the reactive expression for the prediction
  prediction <- reactive({
    # Construct the request
    url <- "https://positconnect.med.miami.edu/content/6ceebf29-1af5-4606-88d0-0b82f9e0223b/predict"
    query <- list(
      bill_length_mm = input$bill_length_mm,
      bill_depth_mm = input$bill_depth_mm,
      flipper_length_mm = input$flipper_length_mm,
      body_mass_g = input$body_mass_g
    )
    response <- GET(
      url, 
      query = query, 
      # this key is from the Posit Connect API and stored in the .Renviron file
      add_headers(Authorization = paste("Bearer", token = Sys.getenv('penguin_key')))
    )
    
    # If the API is returning JSON:
    result <- content(response, "parsed")
    
    # printing to the console for debuggin the API call
    # print(glue::glue("length of response is: {length(response)}"))
    # print(glue::glue("response is: {response}"))
    # print(glue::glue("result is: {result}"))
    
    # Extract the probabilities and map them to the species
    probabilities <- unlist(result)
    species <- c("Adelie", "Chinstrap", "Gentoo")
    names(probabilities) <- species
    
    # Return the probabilities as a list
    probabilities
  })
  
  

  # Update images based on prediction when submit button is clicked
  observeEvent(input$submit, {
    # Get the prediction
    pred <- prediction()
    
    output$adelie_img <- renderUI({
      tags$img(src = "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e3/Hope_Bay-2016-Trinity_Peninsula%E2%80%93Ad%C3%A9lie_penguin_%28Pygoscelis_adeliae%29_04.jpg/600px-Hope_Bay-2016-Trinity_Peninsula%E2%80%93Ad%C3%A9lie_penguin_%28Pygoscelis_adeliae%29_04.jpg", width = paste0(pred["Adelie"]*100, "%"), class = "shiny-image-output")
    })
    output$chinstrap_img <- renderUI({
      tags$img(src = "https://upload.wikimedia.org/wikipedia/commons/thumb/0/08/South_Shetland-2016-Deception_Island%E2%80%93Chinstrap_penguin_%28Pygoscelis_antarctica%29_04.jpg/330px-South_Shetland-2016-Deception_Island%E2%80%93Chinstrap_penguin_%28Pygoscelis_antarctica%29_04.jpg", width = paste0(pred["Chinstrap"]*100, "%"), class = "shiny-image-output")
    })
    output$gentoo_img <- renderUI({
      tags$img(src = "https://upload.wikimedia.org/wikipedia/commons/e/eb/Gentoo_penguin.jpg", width = paste0(pred["Gentoo"]*100, "%"), class = "shiny-image-output")
    })
    
    # Create separate outputs for each species and round and add a percent sign
    output$adelie <- renderText({
      glue::glue('{round(prediction()["Adelie"]*100, 2)}%')
    })
    output$chinstrap <- renderText({
      glue::glue('{round(prediction()["Chinstrap"]*100, 2)}%')
    })
    output$gentoo <- renderText({
      glue::glue('{round(prediction()["Gentoo"]*100, 2)}%')
    })
  })
  
  # Reset the inputs
  observeEvent(input$reset, {
    updateNumericInput(session, "bill_length_mm", value = 46.8)
    updateNumericInput(session, "bill_depth_mm", value = 16.1)
    updateNumericInput(session, "flipper_length_mm", value = 215)
    updateNumericInput(session, "body_mass_g", value = 5500)
  })
}

shinyApp(ui = ui, server = server)