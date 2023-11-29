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
  numericInput("bill_length_mm", "Bill length (mm)", value = 46.8),
  numericInput("bill_depth_mm", "Bill depth (mm)", value = 16.1),
  numericInput("flipper_length_mm", "Flipper length (mm)", value = 0),
  numericInput("body_mass_g", "Body mass (g)", value = 5500),
  actionButton("submit", "Submit"),
  verbatimTextOutput("prediction")
)

server <- function(input, output) {
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
    )
    
    # print the response to the console to debug
    # print(response)
    
    # If the API is returning JSON:
    result <- content(response, "parsed")
    
    # If the API is returning XML:
    # result <- xml2::as_list(xml2::read_xml(response))
    
    # Convert the result to a character vector
    paste(unlist(result), collapse = ", ")
  })
  
  output$prediction <- renderText({
    prediction()
  })
}

shinyApp(ui = ui, server = server)