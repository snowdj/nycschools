library(ggplot2)
library(readr)
library(tidyverse)
library(dplyr)
library(leaflet)
library(sp)
library(ggmap)
library(maptools)
library(broom)
library(httr)
library(rgdal)
library(reshape2)


#load tract data
load('/data/nycdoe/nyc_tracts.Rdata')

#load("/data/nycdoe/clean_data/students_go_to_school_join_county_join_latlong_join_name.Rdata")
load("/data/nycdoe/clean_data/df_for_shiny_map.Rdata")

#################################
#df_for_shiny_map_2012 <- student_go_to_schools_join_county_join_latLong_join_name %>% filter(year == 2012) %>% select(year, dbn, census_tract,county, numStudents, lon, lat, `Location Name` )
#save(df_for_shiny_map_2012, file = "/data/nycdoe/clean_data/df_for_shiny_map.Rdata")
#################################

#nice school icon
school_icon <- makeIcon(
  iconUrl = "http://www.freeiconspng.com/uploads/high-school-icon-png-8.png",
  iconWidth = 38, iconHeight = 38)


#function take dbn and make map
get_map_from_dbn <- function(my_dbn){
  
  sample_map_data <- df_for_shiny_map_2012 %>% 
    filter(dbn == my_dbn & year == 2012)
  
  tracts_map <- merge(nyc_tracts, sample_map_data, by.x = c("TRACTCE","COUNTYFP"), by.y =c("census_tract", "county"))
  
  pal3 <- colorNumeric(palette = "Reds",
                       domain = range(tracts_map@data$numStudents, na.rm=T), na.color = "#cccccc")
  
  leaflet(tracts_map) %>%
    #addPolygons(data = dbns, color = "black") %>%
    addPolygons(weight = .5, fillColor = ~pal3(numStudents), popup = ~paste("Number of Students:", numStudents), fillOpacity = .7) %>% 
    addLegend(pal = pal3, values = ~numStudents, opacity = 1, labFormat = labelFormat(suffix = " students"),
              title = "Distribution of Where </br> Students Live </br> Relative to their</br> School") %>%
    addMarkers(~lon, ~lat, icon = school_icon, label = ~`Location Name`) %>%
    addProviderTiles("CartoDB.Positron") %>%
    setView(-73.972, 40.71, zoom = 11)
    #setView(-73.98, 40.75, zoom = 12)
}


get_map_from_dbn("10X368")

#styvesant -specialized school Manhattan dbn: 02m475
#intech academy (local hs -non-special- Bronx) 10X368
#baruch college hs good non special school 02M411
#Beonx hs of science special in bronx dbn  10X445
# NEW EXPLORATIONS INTO SCIENCE, TECHNOLOGY AND MATH HIGH SCHOOL top school 01M539


