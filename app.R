
library(shinydashboard)
library(tidyverse)
library(tidymodels)
library(xgboost)

model <- readRDS("resorts_model.rds")

data <- read.csv("resorts_app.csv") %>% 
    select(-X)

## app.R ##
ui <- dashboardPage(skin = "blue",
                    dashboardHeader(title = "Ski Resorts App"),
                    dashboardSidebar(
                        menuItem("Price",
                                 tabName = "price_tab", icon = icon("snowflake"))
                    ),
                    dashboardBody(
                        tabItem("price_tab",
                                box(background = "light-blue",selectInput("v_country", label = "Country",
                                                                          choices = unique(data$country))),
                                box(sliderInput("v_elevation_length", label = "Elevation Length (m)",
                                                min = 400, max = 3000, value = 1000)),
                                box(sliderInput("v_highest_point", label = "Highest Point (m)",
                                                min = 1000, max = 3600, value = 2000)),
                                box(sliderInput("v_blue_runs", label = "Blue Runs (km)",
                                                min = 0, max = 700, value = 50)),
                                box(sliderInput("v_red_runs", label = "Red Runs (km)",
                                                min = 0, max = 350, value = 50)),
                                box(sliderInput("v_ski_lifts", label = "Ski Lifts",
                                                min = 0, max = 172, value = 50)),
                                box(sliderInput("v_black_runs", label = "Black Runs (km)",
                                                min = 0, max = 325, value = 50)),
                                box(valueBoxOutput("price_prediction", width = 20), width = 3)
                                
                        )
                    )
)

server <- function(input, output) {
    
    output$price_prediction <- renderValueBox({
        
        prediction <- predict(model,
                              tibble("country" = input$v_country,
                                     "elevation_length" = input$v_elevation_length,
                                     "highest_point" = input$v_highest_point,
                                     "blue_runs" = input$v_blue_runs,
                                     "red_runs" = input$v_red_runs,
                                     "ski_lifts" = input$v_ski_lifts,
                                     "black_runs" = input$v_black_runs)
        )
        
        valueBox(
            value = paste0("€ ", round(prediction, 2)),
            subtitle = "Price Prediction",
            width = 9,
            color = "light-blue",
            icon = icon("credit-card")
        )
    })
    
}

shinyApp(ui, server)
