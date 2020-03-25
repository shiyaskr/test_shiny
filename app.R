library(shinydashboard)

if (interactive()) {
    
    
    header <- dashboardHeader(title ="Venomous Serpent Analysis",titleWidth = 300)
    
    sidebar <- dashboardSidebar(
        sidebarUserPanel(Sys.info()[["user"]],
                         subtitle = a(href = "", icon("circle", class = "text-success"), "Online")),
        
        sidebarMenu(
            
            id = "tabs",
            menuItem("Reports", icon = icon("chart-bar","fa-1.5x", lib = "font-awesome"), tabName = "widgets"),
            menuItem("Map", icon = icon("th"),
                     menuSubItem("Sub-item 1", tabName = "subitem1"),
                     menuSubItem("Sub-item 2", tabName = "subitem2")
            )
        )
    )
    
    
    
    body <- dashboardBody(
        tabItems(
            tabItem("dashboard",
                    div(p("Dashboard tab content"))
            ),
            tabItem("widgets",
                    "Widgets tab content"
            ),
            tabItem("subitem1",
                    "Sub-item 1 tab content"
            ),
            tabItem("subitem2",
                    "Sub-item 2 tab content"
            )
        )
    )
    
    
    
    ui <- dashboardPage(header, sidebar,body, skin = "red")
    server <- function(input, output) {}
    
    shinyApp(ui, server)
}
