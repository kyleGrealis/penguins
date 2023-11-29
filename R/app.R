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
  numericInput("input1", "Bill length (mm)", value = 46.8),
  numericInput("input2", "Bill depth (mm)", value = 16.1),
  numericInput("input3", "Flipper length (mm)", value = 0),
  numericInput("input4", "Body mass (g)", value = 5500),
  actionButton("submit", "Submit"),
  verbatimTextOutput("prediction")
)

server <- function(input, output) {
  prediction <- eventReactive(input$submit, {
    # Construct the request
    url <- "https://positconnect.med.miami.edu/content/6ceebf29-1af5-4606-88d0-0b82f9e0223b/predict"
    body <- list(
      bill_length_mm    = input$input1,
      bill_depth_mm     = input$input2,
      flipper_length_mm = input$input3,
      body_mass_g       = input$input4
    )
    
    # Convert the body to JSON
    body_json <- toJSON(body)
    
    # Send the request and parse the response
    response <- POST(
      url, body = body_json, 
      add_headers("Content-Type" = "application/json"),
      timeout(60)
    )
    json_response <- content(response, "parsed")
    
    # Convert the JSON response to a string
    json_string <- toJSON(json_response, pretty = TRUE)
    json_string
  })
  
  output$prediction <- renderText({
    prediction()
  })
}

shinyApp(ui = ui, server = server)