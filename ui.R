require(shinydashboard)
require(shinythemes)
require(shiny)
require(leaflet)
require(dygraphs)

dashboardPage(skin = 'blue',
              dashboardHeader(title = 'WaterExplorer'),
                dashboardSidebar(
                  sidebarMenu(
                    menuItem('Surface Stations', tabName = 'surface', icon = icon('line-chart'))
                    
                  )
                ),
                dashboardBody(
                 h5("Select Date Range, and Parameter.  Zoom into map and select (by clicking) the USGS station of interest."),
                 h5("Note: Some stations may not have data for your specified date range."),
                   tabItems(
                    tabItem(tabName = 'surface',
                            fluidRow(
                              box(collapsible=T, width=6,
                                  leafletOutput('StationMap')),
                              box(collapsible = T, 
                                  dateRangeInput('surfaceDateRange', 'Date Range:', 
                                                 start = Sys.Date() - 30, 
                                                 end = Sys.Date(),
                                                 format = 'yyyy-mm-dd'),
                                  selectInput('parameterCode', 'Parameter:', choices = c("Gage Height, ft" = "00065", "Discharge cfs" = "00060"), multiple=FALSE, selectize=TRUE, selected = '00060'))
                                  ##dataTableOutput("returnedData"))
                            ),
                            fluidRow(
                              dygraphOutput("dyGraphDV")
                            ))
                   
                  )
                )
              )
              
