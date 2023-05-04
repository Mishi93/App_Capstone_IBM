# Install and import required libraries
require(shiny)
require(ggplot2)
require(leaflet)
require(tidyverse)
require(httr)
require(scales)
# Import model_prediction R which contains methods to call OpenWeather API
# and make predictions
source("model_prediction.R")


test_weather_data_generation<-function(){
  #Test generate_city_weather_bike_data() function
  city_weather_bike_df<-generate_city_weather_bike_data()
  stopifnot(length(city_weather_bike_df)>0)
  print(head(city_weather_bike_df))
  return(city_weather_bike_df)
}


# Create a RShiny server
shinyServer(function(input, output){
  # Define a city list
  
  # Define color factor
  color_levels <- colorFactor(c("green", "yellow", "red"), 
                              levels = c("small", "medium", "large"))

  city_weather_bike_df <- test_weather_data_generation()

  
  # Create another data frame called `cities_max_bike` with each row contains city location info and max bike
  # prediction for the city
  cities_max_bike <- city_weather_bike_df %>%
    group_by(CITY_ASCII,LNG,LAT,BIKE_PREDICTION,BIKE_PREDICTION_LEVEL,LABEL,DETAILED_LABEL)%>%
    summarize(max_prediction=max(BIKE_PREDICTION))
   
  # Then render output plots with an id defined in ui.R
  observeEvent(input$city_dropdown, {  
    if(input$city_dropdown != 'All') {
      # If just one specific city was selected, render a leaflet map with one marker on the map and a popup
      # with DETAILED_LABEL displayed
      selected_city <- filter(cities_max_bike, CITY_ASCII == input$city_dropdown)
     output$city_bike_map<-renderLeaflet({
       leaflet(selected_city) %>%
        addTiles() %>%
        addMarkers(
          lng = ~LNG,
          lat = ~LAT,
          popup = ~DETAILED_LABEL
        )
       })
     select_city<-filter(city_weather_bike_df, CITY_ASCII==input$city_dropdown)
     output$temp_line<-renderPlot({
       ggplot(select_city,aes(as.POSIXct(FORECASTDATETIME),TEMPERATURE,group=CITY_ASCII))+
         geom_line(color="yellow")+
         geom_point(size=2)+
         geom_text(aes(label=TEMPERATURE)) +
         xlab("Time (3 hours ahead)") + ylab("Temperature in celcius")+
         ggtitle("Temperature Chart")
     })
     output$bike_line<-renderPlot({
       ggplot(select_city,aes(FORECASTDATETIME,BIKE_PREDICTION,group=CITY_ASCII))+
         geom_line(color="blue",linetype = "dashed")+
         geom_point(size=2)+
           geom_text(aes(label=BIKE_PREDICTION))+
         xlab("Time (3 hours ahead)")+ylab("Bike prediction")+
         ggtitle("Predictions")
          })
     output$bike_date_output <- renderText({
       if (!is.null(input$plot_click)) {
         point <- nearPoints(select_city, input$plot_click)
         paste0("Date: ", point$FORECASTDATETIME, "\n",
                "Bike Prediction: ", point$BIKE_PREDICTION)
       }
         })
     output$humidity_pred_chart<-renderPlot({
       ggplot(select_city,aes(HUMIDITY,BIKE_PREDICTION))+
         geom_point(size=2)+
         geom_smooth(method="lm",formula=y ~ poly(x, 4),color="red")+
         xlab("Humidity")+ylab("Bike prediction")+
         ggtitle("Humidity Prediction Chart")
     })
    }else{
      #Render the city overview map
  output$city_bike_map <- renderLeaflet({
    # Complete this function to render a leaflet map
    leaflet(cities_max_bike) %>%
      addTiles()%>%
     addCircleMarkers(popup=~LABEL,
                       lng=~LNG, 
                       lat=~LAT,
                      radius=~ifelse(max_prediction=="small",6,
                             ifelse(max_prediction=="medium",10,12)),
                      color=~color_levels(BIKE_PREDICTION_LEVEL)
                      )
                         
  })   
  }

  # Execute code when users make selections on the dropdown 
  }) 
  
  # If All was selected from dropdown, then render a leaflet map with circle markers
  # and popup weather LABEL for all five cities
  
  # If just one specific city was selected, then render a leaflet map with one marker
  # on the map and a popup with DETAILED_LABEL displayed
  
})
