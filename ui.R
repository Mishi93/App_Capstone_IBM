# Load required libraries
require(leaflet)


# Create a RShiny UI
shinyUI(
  fluidPage(padding=5,
  titlePanel("Bike-sharing Demand Prediction App"),
  h3("Author: Mehwish Younus"),
  # Create a side-bar layout
  sidebarLayout(
    # Create a main panel to show cities on a leaflet map
    mainPanel(
      # leaflet output with id = 'city_bike_map', height = 1000
      leafletOutput("city_bike_map",
                 height="1000px",
                 width="900px")
    ),
    # Create a side bar to show detailed plots for a city
    sidebarPanel(
      # select drop down list to select city
      selectInput(inputId="city_dropdown", 
                  label="Cities",
                  choices=c("All","London","Paris","Suzhou","Seoul","New York"),
                  selected="All"),
      p("Select city from dropdown to show its bike prediction details"),
      plotOutput("temp_line"),
      plotOutput("bike_line",click="plot_click"),
      verbatimTextOutput("bike_date_output"),
      plotOutput("humidity_pred_chart")
      
    )
     
))
)
