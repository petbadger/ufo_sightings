#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#



# Define UI for application that draws a histogram
shinyUI(
  
  fluidPage(theme = shinytheme("superhero"),
            #includeCSS("jump_fix.css"), #https://shiny.rstudio.com/articles/css.html
            useShinyjs(),  # Include shinyjs #http://deanattali.com/shinyjs/overview
    
            tags$head( #https://shiny.rstudio.com/articles/validation.html
                tags$style(HTML("
                  .shiny-output-error-validation {
                    color: green; font-weight: bold;
                  }
                  #nobs_avail{color: #cccccc;
                    font-size: 0.8em;
                    font-style: italic;
                  }
              "))
            ),
          
              
  fluidRow(
    titlePanel("UFO Sightings"),
    
    column(3, id = "side-panel-1",
           
           h4("Filter on Date, Duration"),
           
       
      selectInput("theDuration","Select sighting duration:",choices = listdurationdescr()),

        sliderInput("sightYear", "Sighting year:", min = min(minmaxyear()),sep = "", max = max(minmaxyear()), value=max(minmaxyear()), step = 1, animate=animationOptions(interval=1800, loop=TRUE) ),
            #https://stackoverflow.com/questions/26636335/formatting-number-output-of-sliderinput-in-shiny

        actionButton("reset_input", "Reset these filters") #https://stackoverflow.com/questions/24265980/reset-inputs-button-in-shiny-app
       
    ),
    
    column(3,id="side-panel-2", 
           #offset = 1,
           h4("Filter Data"),
           #since only allowed to view 1 year at a time, table() function shows max Freq/year. 
           #Can limit obs slider to the max freq/year.
           sliderInput("obs", "Number of observations to view:", 1, 7500, 100,
                       step = 10, animate=animationOptions(interval=600, loop=TRUE)
           ),
           textOutput("nobs_avail"),
           br(),
           actionButton("reset_input2", "Reset these filters")
           
    ),
    column(3, id = "side-panel-3",
       
       h4("Filter on Location"),
       selectInput("theCountry","Select Country:",choices = listcountries()),
       selectInput("theState","Select State (choose country first):",choices = liststates()), 
       actionButton("reset_input3", "Reset these filters")
       
    ),
    column(3, id = "side-panel-4",
       
       h4("Filter on Shape"),
       selectInput("theShape2","Select shape:",choices = listshapes()),
       #selectizeInput('theShape2', 'Select Shapes', choices = listshapes(), multiple = TRUE),
       actionButton("reset_input4", "Reset these filters")
    )

  ),

hr(),

fluidRow(
  
  tabsetPanel(type = "tabs", 
			  tabPanel("Getting Started", 
                       includeMarkdown("get_started.md")
                       
                       ),
              tabPanel("Map", leafletOutput("mapPlot",  width = "100%", height = 500), 
                       actionButton("zoomButton", "Zoom to fit locations")
              ), 
              tabPanel("Data", 
                       hr(),
                       dataTableOutput("dataview")
              ), 
              
              tabPanel("Wordcloud", p("Select filters, then build worldcloud. Wordcloud based on Ufo sighting comments."), 
                       actionButton("buildWordcloud", "Build the Wordcloud"), br(), br(),  
                       plotOutput("plot") ),
              tabPanel("About", 
                       includeMarkdown("index.md")
                       
                       )
  )
),


  hr(),
  br(),br(),br()
))
