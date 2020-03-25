library(shiny)

library(dplyr)

library(leaflet)

library(DT)

library(readr)

library(tidyr)  

library(ggplot2)

library(png)

shinyServer(function(input, output, session) {
    
    toggleModal(session, "startupModal", toggle = "open")
    
    # Import Data and clean it
    regionwise_filepath <-  "../SourceData/Regionwise Snake Data.csv"
    hosp_filepath <- "../SourceData/HospitalData.csv"
    
    regionwise_snakes <- read_csv(regionwise_filepath)
    hospitals <- read_csv(hosp_filepath)

regionwise_snakes <- regionwise_snakes %>% 
        group_by(Region, Category) %>% 
        mutate(Number_of_Snake_Species = n())  
    
regionwise_snakes <- regionwise_snakes %>% 
        mutate(Snake_new = trimws(Snake),
               tooltip_snakes = paste0('<strong>Snake: </strong>',Snake,
                                       '<br><strong>Category:</strong> ', Category,
                                       '<br><strong>Region:</strong> ',Region))

color_pal <- colorFactor(pal = c("#34eb3a", "#ed0c0c"), domain = c( "Non Venomous", "Venomous"))



hospIcons <- iconList(
    hosp = makeIcon("../SourceData/hosp.png", iconWidth = 38, iconHeight = 61,
                    iconAnchorX = 22, iconAnchorY = 80)
)


snakeicons <- icons(
    iconUrl = ifelse(regionwise_snakes$Category == "Venomous",
                     "../SourceData/BSnake.png",
                     "../SourceData/GSnake.png"
    ),
    iconWidth = 38, iconHeight = 61,
    iconAnchorX = 22, iconAnchorY = 80) 
    
    hospitals <- hospitals %>% 
    mutate(tooltip = paste0('<strong>Name: </strong>',NAME,
                            '<br><strong>Address:</strong> ', ADDRESS,
                            '<br><strong>Telephone:</strong> ',TELEPHONE))
    
    
    pal <- colorFactor(pal = c("#1b9e77", "#d95f02", "#7570b3"), domain = c("GOVERNMENT - DISTRICT/AUTHORITY", "GOVERNMENT - FEDERAL", "GOVERNMENT - STATE"))
    
    
    # create the leaflet map  
    output$bbmap <- renderLeaflet({
        leaflet(regionwise_snakes) %>% addTiles() %>% 
            setView(-96, 37.8, 7) %>% 
            addProviderTiles(providers$Esri.NatGeoWorldMap) %>% 
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
    })
    
    
    output$bbmap1 <- renderLeaflet({
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
                icon = "fa-globe", title = "Zoom to Level 8",
                onClick = JS("function(btn, map){ map.setZoom(8);}")))
    })
    
    output$bbmap2 <- renderPlotly({
        plot <- ggplot(regionwise_snakes, aes(Region, Number_of_Snake_Species, fill= Category)) %>% 
            plot + geom_bar(stat = "identity", position = 'dodge', colour="black")  +
            coord_flip() + theme_fivethirtyeight() + scale_fill_fivethirtyeight() +
            guides(fill=guide_legend(title=NULL)) 
        plot + labs(title = "Number of Snake Species Per Region",
                    subtitle = "Plot of Venomous and Non Venomous Serpents")
        plot <- ggplotly(plot)
    })
    
    output$myImage <- renderImage({
        
        filename <- normalizePath(file.path('../SourceData/report-min.png'))
        
        # Return a list containing the filename
        list(src = filename)
        
    },deleteFile = FALSE)
    
    output$myImage2 <- renderImage({
        
        filename <- normalizePath(file.path('../SourceData/report2.png'))
        
        # Return a list containing the filename
        list(src = filename)
        
    },deleteFile = FALSE)
    
   
    
})