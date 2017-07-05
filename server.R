require(dataRetrieval)
require(leaflet)
require(dygraphs)



shinyServer(function(input, output, session) {
  # Data for leaflet map on surface tab
  surfaceWaterPoints <- reactive({
    sites <- whatNWISsites(stateCd="FL", outputDataTypeCd = c("id", "iv", "dv"), siteType = c("ST", "LK", "ES", "OC"), parameterCd=input$parameterCode, startDt = input$surfaceDateRange[1], endDt = input$surfaceDateRange[2])
  })
  
  # 
  surfaceMapAvailableData <- reactive({
    if(map.data$clickedMarker$group == "Surfacewater"){
      marker <- map.data$clickedMarker$id
      returned.data <- whatNWISdata(siteNumber = marker,
                                    parameterCd = input$parameterCode)
      returned.data <- returned.data[,c("parm_cd", "site_no", "station_nm", "site_tp_cd", "begin_date","end_date", "alt_va", "alt_datum_cd", "data_type_cd")]
      ## pc <- data.frame(parm_cd = parameterCodes, name=names(parameterCodes))
      ## returned.data <- merge(returned.data, pc, by="parm_cd")
    }
  })
  
  #surface data
  surfaceData <- reactive({
    if(map.data$clickedMarker$group == "Surfacewater"){
      marker <- map.data$clickedMarker$id
      returned.data <- readNWISdv(siteNumber = marker,
                                  parameterCd = input$parameterCode,  
                                  startDate = as.character(input$surfaceDateRange[1]), 
                                  endDate = as.character(input$surfaceDateRange[2]))
      
      print(returned.data)
      dygraphData <- returned.data[,4]
      names(dygraphData) <- returned.data$Date
      return(dygraphData)
    } else {
      return(1:100)
    }
  })
  
  output$StationMap <- renderLeaflet({
    leaflet() %>%
      addProviderTiles("Stamen.Toner", group = "Toner") %>%
      ##setView(lng = -83.65, lat = 27.9, zoom=5.8) %>%
      
      addCircleMarkers(data = surfaceWaterPoints(),
                       lat = ~dec_lat_va,
                       lng = ~dec_long_va,
                       popup = ~station_nm,
                       radius = 1.5,
                       layerId = ~site_no,
                       group="Surfacewater",
                       color= 'red')
     
  })
  
  #map reactives
  map.data <- reactiveValues(clickedMarker=NULL)
  
  #map observers
  observeEvent(input$StationMap_marker_click, {
    if(input$StationMap_marker_click$group == 'Surfacewater'){
      map.data$clickedMarker <- input$StationMap_marker_click
      output$dyGraphDV <- renderDygraph({
        smd <- surfaceWaterPoints()
        dygraph(surfaceData(), main = smd[smd$site_no == map.data$clickedMarker$id,"station_nm"]) %>% 
          dyRangeSelector() %>%
          dyRoller(rollPeriod = 1)
      })
    }
  })
  output$returnedData <- renderDataTable({
    req(surfaceMapAvailableData())
    surfaceMapAvailableData()})
  
})