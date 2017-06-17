#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#


# Define server logic required to draw a histogram
shinyServer(function(input, output, session) { 
  

  
  reactive({ input$update})
  
  scrub <- reactive({
    
   data <- scrubbed %>% select(lat, long, country, city, shape, duration_descr, state, comments, duration, year, month, day, seconds, minutes)

    if( input$theDuration != "All" ){
     
      data <- data %>% filter(duration_descr == input$theDuration)
    }
    if( input$theShape2 != "All" ){
    
      data <- data %>% filter(shape == input$theShape2)
    }
    if( input$theCountry != "All" ){
     
      data <- data %>% filter(country == input$theCountry)
      
    }
    if( input$theState != "All" ){
     
      data <- data %>% filter(state == input$theState)
      
    }
    if( length(input$sightYear) == 0 ){
      #removed the one NA
      data <- data %>% filter(year == 2014)
    }else{
      data <- data %>% filter(year %in% input$sightYear)
    }
    
    #get total obs available once filtered
    nobs_avail_txt <- nrow(data)
    #important not to use nrow(data) in the render* because it will grab the result nrow of reactive scrub()
    output$nobs_avail <- renderText({ paste("Observations available:", formatC(nobs_avail_txt, format = "d", big.mark = ",") ) }) 
    
    #if ( !is.na(input$obs) ){ #this checks that obs is no na, but it would never be that since it's not an option in the slider.
    #  data <- data[1:input$obs,]
    #}
    #The problem with this is that it it will force the creation of empty rows if nrow's is less than that of nobs.
    #This results in blank lat longs.
    #Instead, we need to check how many records there are. If nrow is less than nobs, then don't limit the vector
    
    if ( nrow(data) > input$obs ){
      data <- data[1:input$obs,]
    }
    
   
    validate(need(nrow(data) > 0, message = "Whoops. Filtered to empty data set." ) ) 
    check <- data
    data
   
    
  })
  
  #for zoom button
  lastZoomButtonValue <- NULL
  
  
  output$mapPlot <- renderLeaflet({
  
    map <- leaflet(data = scrub() ) %>% addTiles() %>%
      addMarkers(~long, ~lat, icon=ufoIcon, popup=~paste("<p style='color: #000000; background-color: #ffffff'>",
                                                         "<b>Shape: </b>", scrub()$shape,"</br>", 
                                                               "<b>Date: </b>", scrub()$month, scrub()$day, scrub()$year, "</br>",
                                                               "<b>Duration: </b>", scrub()$duration, "</br>",
                                                               "<b>City: </b>", scrub()$city, "<b> State: </b>", scrub()$state,"<b> Country: </b>", scrub()$country, "</br>",
                                                               "<b>Comment: </b>", scrub()$comments,"</br></p>"), 
                 #options = popupOptions(syles=WMS)
                 label=~htmlEscape(shape), clusterOptions = markerClusterOptions())
    
    rezoom <- "first"
    # If zoom button was clicked this time, and store the value, and rezoom
    if (!identical(lastZoomButtonValue, input$zoomButton)) {
      lastZoomButtonValue <<- input$zoomButton
      rezoom <- "always"
    }
    
    map <- map %>% mapOptions(zoomToLimits = rezoom)
    
    map
    
    
    
    
  })
  
 
  #Wordcloud
#  terms <- reactive({
    # Change when the "update" button is pressed...
#    input$update
    # ...but not for anything else
#    isolate({
#      withProgress({
#        setProgress(message = "Processing corpus...")
#        getTermMatrix(input$selection)
#      })
#    })
#  })
  
  # Make the wordcloud drawing predictable during a session
  #wordcloud_rep <- repeatable(wordcloud)
  
  output$plot <- renderPlot({
    
    input$buildWordcloud
    
    #https://stackoverflow.com/questions/26711423/how-can-i-convert-an-r-data-frame-with-a-single-column-into-a-corpus-for-tm-such
    #Import your data into a "Source", your "Source" into a "Corpus", and then make a TDM out of your "Corpus":
    
    corp <- Corpus(DataframeSource(as.data.frame( isolate(scrub() )  ))) #isolate scrub?
    corp <- tm_map(corp, stripWhitespace)
    corp <- tm_map(corp, tolower)
    corp <- tm_map(corp, removePunctuation)
    corp <- tm_map(corp, removeWords, stopwords("english"))
    corp <- tm_map(corp, stemDocument)
    
    corp <- tm_map(corp, PlainTextDocument) #put the corpus back into the correct data type
    
    wordcloud(corp, scale=c(10,1), max.words=30, random.order=FALSE, 
              rot.per=0.35, use.r.layout=FALSE, colors=brewer.pal(8, "Dark2"))
    
    
    
  })
  
 
  observeEvent(input$reset_input, {
    reset("side-panel-1")
  })
  observeEvent(input$reset_input2, {
    reset("side-panel-2")
  })
  observeEvent(input$reset_input3, {
    reset("side-panel-3")
  })
  observeEvent(input$reset_input4, {
    reset("side-panel-4")
  })
  

  
  # Show the first "n" observations
  output$dataview <- DT::renderDataTable({
    datatable(
    scrub() %>% select(year, month, day, country, state, shape, seconds, minutes, comments),filter="top", 
    selection = "none",
    options = list(lengthMenu = c(5, 10, 25), pageLength = 5, sDom  = '<"top">flrt<"bottom">ip'), style = 'bootstrap',
    ,callback=JS("
           //hide column filters for the first two columns
          $.each([0,1,2,3,4,5,6,7,8], function(i, v) {
                $('input.form-control').eq(v).hide()
          });" ))
  })
  #https://stackoverflow.com/questions/35624413/remove-search-option-but-leave-search-columns-option
  #http://legacy.datatables.net/usage/options
  #https://rstudio.github.io/DT/options.html

  observe({
    x <- input$theCountry
    
 
    # Can also set the label and select items
    updateSelectInput(session, "theState",
                      #label = paste("Select input label", length(x)),
                      choices = liststates(x)
                      #selected = tail(x, 1)
                      )
  })
  
  
#  output$validDateRange <- renderText({
    # make sure end date later than start date
#    validate(
#      need( as.POSIXct(input$sightDateRange[2]) > as.POSIXct(input$sightDateRange[1]), "end date is earlier than start date"
#      )
#    )
   
    
#    paste("<i>Date range is ", 
#          difftime(as.POSIXct(input$sightDateRange[2]), as.POSIXct(input$sightDateRange[1]), units="days"),
#          "days apart.</i>")
#  })
 
  #output$noData <- renderText({
  #  paste("If no data appears, try changing the filters")
  #})

  
})
