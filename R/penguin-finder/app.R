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

penguin_key <- config::get("penguin_key")
# source("penguin_key.R")

# creating the ui ----
ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      body {
        transform: scale(1.25);
        transform-origin: top center;
        margin: auto;
        background-image: url('antarctica.jpg');
        background-repeat: no-repeat;
        background-size: cover;
        color: white;
        max-width: 850px;
      }
      .shiny-image-output {
        display: block;
        margin: auto;
        max-width: 150px;
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
      style = "color: black;"
    ),
    
    mainPanel(
      h2("You are..."),
      p("an ornithologist studying the migratory patterns of the local penguins at the Palmer Station, Antarctica LTER (Long Term Ecological Research Network) on the Palmer archipelago. You are in the southwestern Antarctic when you encounter a colony of penguins and you want to know what type they are."),
      p("You've measured a penguin's bill length, bill depth, flipper length, and body mass. You can now enter these measurements into the app and it will predict the species of penguin you found."),
      
      uiOutput("predicted_species_header"),
      
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



# creating the server ----
server <- function(input, output, session) {
  
  # Initialize images with equal sizes
  output$adelie_img <- renderUI({
    tags$img(
      src = "adelie.jpg", 
      width = "100%", 
      height = "200px", 
      class = "shiny-image-output"
    )
  })
  output$chinstrap_img <- renderUI({
    tags$img(
      src = "chinstrap.jpg", 
      width = "100%", 
      height = "200px", 
      class = "shiny-image-output"
    )
  })
  output$gentoo_img <- renderUI({
    tags$img(
      src = "gentoo.jpg", 
      width = "100%", 
      height = "200px", 
      class = "shiny-image-output"
    )
  })
  
  
  
  # Define the reactive expression for the prediction
  prediction <- eventReactive(input$submit, {
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
      
      # this key is from the Posit Connect API and stored in the config.yml file
      # add_headers(Authorization = paste("Bearer", token = penguin_key))
    )
    
    # If the API is returning JSON:
    result <- content(response, "parsed")
    
    # Extract the probabilities and map them to the species
    probabilities <- unlist(result)
    species <- c("Adelie", "Chinstrap", "Gentoo")
    names(probabilities) <- species
    
    # Return the probabilities as a list
    probabilities
  })
  
  
  
  # show the "predicted probabilities" header when the submit button is clicked
  submitClicked <- reactiveVal(FALSE)
  
  observeEvent(input$submit, {
    submitClicked(TRUE)
  })
  
  output$predicted_species_header <- renderUI({
    if (submitClicked()) {
      h3("Predicted Species")
    }
  })
  
  
  
  # Update images based on prediction when submit button is clicked
  observeEvent(input$submit, {
    # Get the prediction
    pred <- prediction()
    
    # Set the base probability to 20% so that the images are always visible
    base_prob <- 25
    
    output$adelie_img <- renderUI({
      tags$img(
        src = "adelie.jpg", 
        width = paste0(max(base_prob, pred["Adelie"]*100), "%"), 
        class = "shiny-image-output"
      )
    })
    output$chinstrap_img <- renderUI({
      tags$img(
        src = "chinstrap.jpg", 
        width = paste0(max(base_prob, pred["Chinstrap"]*100), "%"), 
        class = "shiny-image-output"
      )
    })
    output$gentoo_img <- renderUI({
      tags$img(
        src = "gentoo.jpg", 
        width = paste0(max(base_prob, pred["Gentoo"]*100), "%"), 
        class = "shiny-image-output"
      )
    })
    
    # Create separate outputs for each species and round and add a percent sign
    output$adelie <- renderText({
      glue::glue('{round(pred["Adelie"]*100, 2)}%')
    })
    output$chinstrap <- renderText({
      glue::glue('{round(pred["Chinstrap"]*100, 2)}%')
    })
    output$gentoo <- renderText({
      glue::glue('{round(pred["Gentoo"]*100, 2)}%')
    })
  })
  
  
  
  # Reset the inputs and outputs when the reset button is clicked
  observeEvent(input$reset, {
    updateNumericInput(session, "bill_length_mm", value = 46)
    updateNumericInput(session, "bill_depth_mm", value = 16)
    updateNumericInput(session, "flipper_length_mm", value = 185)
    updateNumericInput(session, "body_mass_g", value = 5000)
    
    output$adelie_img <- renderUI({
      tags$img(
        src = "adelie.jpg", 
        width = "100%", 
        height = "200px", 
        class = "shiny-image-output"
      )
    })
    output$chinstrap_img <- renderUI({
      tags$img(
        src = "chinstrap.jpg", 
        width = "100%", 
        height = "200px", 
        class = "shiny-image-output"
      )
    })
    output$gentoo_img <- renderUI({
      tags$img(
        src = "gentoo.jpg", 
        width = "100%", 
        height = "200px", 
        class = "shiny-image-output"
      )
    })
    
    output$adelie <- renderText({
      ""
    })
    output$chinstrap <- renderText({
      ""
    })
    output$gentoo <- renderText({
      ""
    })
    
    submitClicked(FALSE)
  })
}

shinyApp(ui = ui, server = server)