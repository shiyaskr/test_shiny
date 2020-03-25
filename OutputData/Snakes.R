library(leaflet)
library(readr)
library(dplyr)
library(DT)



setwd("C:/Users/amrita.krishnan/Desktop/R/ShinyContest/OutputData") ##Seting directory

regionwise_filepath <-  "../SourceData/Regionwise Snake Data.csv"
hosp_filepath <- "../SourceData/HospitalData.csv"

regionwise_snakes <- read_csv(regionwise_filepath)
hospitals <- read_csv(hosp_filepath)

regionwise_snakes <- regionwise_snakes %>% 
  mutate(Snake_new = trimws(Snake),
         tooltip_snakes = paste0('<strong>Snake: </strong>',Snake,
                                 '<br><strong>Category:</strong> ', Category,
                                 '<br><strong>Region:</strong> ',Region))

color_pal <- colorFactor(pal = c("#34eb3a", "#ed0c0c"), domain = c( "Non Venomous", "Venomous"))


snakeicons <- icons(
  iconUrl = ifelse(regionwise_snakes$Category == "Venomous",
                   "../SourceData/BSnake.png",
                   "../SourceData/GSnake.png"
                   ),
  iconWidth = 38, iconHeight = 61,
  iconAnchorX = 22, iconAnchorY = 80) 

leaflet(regionwise_snakes) %>% addTiles() %>% 
  setView(-96, 37.8, 7) %>% 
  addMarkers(regionwise_snakes$longitude,  regionwise_snakes$latitude,
             popup = ~as.character(tooltip_snakes), label  = as.factor(regionwise_snakes$Snake), icon = snakeicons) %>% 
  
  addLegend(pal= color_pal, values=regionwise_snakes$Category,opacity=1, na.label = "Not Available") %>%
  addProviderTiles(providers$CartoDB.DarkMatter, group="Dark") %>%
  addProviderTiles(providers$CartoDB.Positron, group="Light") %>%
  addLayersControl(baseGroups=c('OSM','Dark','Light')) %>%   
  
  addEasyButton(easyButton(
    icon = "fa-crosshairs", title = "Locate Me",
    onClick = JS("function(btn, map){ map.locate({setView: true}); }"))) %>% 
  addEasyButton(easyButton(
    icon = "fa-globe", title = "Zoom to Level 8",
    onClick = JS("function(btn, map){ map.setZoom(8);}")))

