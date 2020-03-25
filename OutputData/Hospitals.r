library(leaflet)
library(readr)
library(dplyr)
library(DT)


setwd("C:/Users/amrita.krishnan/Desktop/R/ShinyContest/OutputData") ##Seting directory


regionwise_filepath <-  "../SourceData/Regionwise Snake Data.csv"
hosp_filepath <- "../SourceData/HospitalData.csv"

regionwise_snakes <- read_csv(regionwise_filepath)
hospitals <- read_csv(hosp_filepath)


hospIcons <- iconList(
  hosp = makeIcon("../SourceData/hosp.png", iconWidth = 38, iconHeight = 61,
                  iconAnchorX = 22, iconAnchorY = 80)
)


hospitals <- hospitals %>% 
  mutate(tooltip = paste0('<strong>Name: </strong>',NAME,
                         '<br><strong>Address:</strong> ', ADDRESS,
                         '<br><strong>Telephone:</strong> ',TELEPHONE))

pal <- colorFactor(pal = c("#1b9e77", "#d95f02", "#7570b3"), domain = c("GOVERNMENT - DISTRICT/AUTHORITY", "GOVERNMENT - FEDERAL", "GOVERNMENT - STATE"))

leaflet(data = hospitals) %>% addTiles() %>%
  addProviderTiles(providers$Esri.NatGeoWorldMap) %>% 
  setView(-96, 37.8, 9) %>% 
  addMarkers(~LONGITUDE, ~LATITUDE, popup = ~as.character(tooltip), label = ~as.character(NAME), icon = hospIcons) %>% 
  addLegend(pal=pal, values=hospitals$OWNER,opacity=1, na.label = "Not Available") %>%
  addProviderTiles(providers$CartoDB.DarkMatter, group="Dark") %>%
  addProviderTiles(providers$CartoDB.Positron, group="Light") %>%
  addLayersControl(baseGroups=c('OSM','Dark','Light')) %>% 
  
  addEasyButton(easyButton(
    icon = "fa-crosshairs", title = "Locate Me",
    onClick = JS("function(btn, map){ map.locate({setView: true}); }"))) %>% 
  addEasyButton(easyButton(
    icon = "fa-globe", title = "Zoom to Level 5",
    onClick = JS("function(btn, map){ map.setZoom(7);}")))
