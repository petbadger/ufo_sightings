listcountries <- function(){
  vect <- c("All", sort(unique(scrubbed$country), decreasing = FALSE) )
  
  vect <- vect[!is.na(vect)]
  
  return (vect)
}



liststates <- function(cntry=NULL){
  if(missing(cntry)) {
    vect <- c("All", sort(unique(scrubbed$state), decreasing = FALSE) )
  } else {
    
    vect <- scrubbed %>% select(country, state) %>% filter(country == cntry) %>% select(state) %>% unique()
    vect <- c("All", sort(vect[["state"]], decreasing = FALSE) )
    
  }
 
  vect <- vect[!is.na(vect)]
  return (vect)
}


#https://stackoverflow.com/questions/31450477/how-to-populate-drop-down-menu-in-shinys-ui-r-using-rscript-code


listshapes <- function(){
 
  vect <- c("All", sort(unique(scrubbed$shape), decreasing = FALSE) ) #table(as.factor(scrubbed$country))
 
  vect <- vect[!is.na(vect)]
  
  return (vect)
}



minsmax <- function() {
  max(scrubbed$minutes, na.rm = TRUE)
}




listyears <- function() {
  
  
    #don't inlude an "All" because it's too much data
  vect <- c(unique(scrubbed$year)) #table(as.factor(scrubbed$country))
  #vect <- levels(scrubbed$shape)
  vect <- sort(vect, decreasing = TRUE)
  vect <- vect[!is.na(vect)]
  return (vect)
}

minmaxyear <- function() {
  
  vect <- c(min(scrubbed$year, na.rm = TRUE), max(scrubbed$year, na.rm = TRUE))
  
  return (vect)
}


#maxfreqperyear <- as.data.frame(table(scrubbed$year)) %>% arrange(Freq)
#tail(maxfreqperyear$Freq, n=1)
##7308


obsmax <- function() {
  nrow(scrubbed)
}

listdurationdescr <- function(){
 
  #format is shiny app label = value in the data
  vect <- c("All" = "All", 
            "< 5 sec" = "Less than 5 seconds",
            "5 - 29 sec" = "5 seconds to less than 30 seconds",
            "30 - 59 sec" = "30 seconds to less than 1 minute",
            "1 - 4:59 min" = "1 minute to less than 5 minutes",
            "5 - 9:59 min" = "5 minute to less than 10 minutes",
            "10 - 29:59 min" = "10 minutes to less than 30 minutes",
            "30 - 59:59 min" = "30 minutes to less than 1 hour",
            "1 - 23:59:59 hours" = "1 hour to less than 24 hours",
            "24+ hours" = "Greater than 24 hours",
            "Unknown" = "Unknown"
  )
  return(vect)
}

