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
  numericInput("input1", "Input 1", value = 0),
  numericInput("input2", "Input 2", value = 0),
  numericInput("input3", "Input 3", value = 0),
  numericInput("input4", "Input 4", value = 0),
  actionButton("submit", "Submit"),
  textOutput("prediction")
)

server <- function(input, output) {
  prediction <- eventReactive(input$submit, {
    # Construct the request
    url <- "https://positconnect.med.miami.edu/content/6ceebf29-1af5-4606-88d0-0b82f9e0223b/openapi.json"
    body <- list(
      input1 = input$input1,
      input2 = input$input2,
      input3 = input$input3,
      input4 = input$input4
    )
    
    # Send the request and parse the response
    response <- POST(url, body = body)
    content(response)$probability
  })
  
  output$prediction <- renderText({
    paste("Predicted probability:", prediction())
  })
}

shinyApp(ui = ui, server = server)