# Import Data
scrubbed <- readRDS("data/scrubbed.rdata")

library(dplyr)

#scrubbed$comments <- gsub('&#44', '', scrubbed$comments)
#scrubbed$comments <- scrubbed$country %>% str_replace("&#44", "")
#test <- str_replace(scrubbed$country, "&#44", "")
#scrubbed$comments <- gsub("&#[a-z0-9][a-z0-9]", '', scrubbed$comments)


library(readr)


scrubbed <- read_csv("scrubbed.csv", 
                     col_types = cols(`date posted` = col_datetime(format = "%m/%d/%Y"), 
                                      datetime = col_datetime(format = "%m/%d/%Y %H:%M"), 
                                      latitude = col_character(), 
                                      longitude = col_character()
                                      ))





hdr <- c("datetime", "city", "state", "country", "shape", "seconds", "duration", "comments", "posting", "lat", "long")

names(scrubbed) <- hdr

#read in lat long as char so it won't do padding of 0's. I don't know how to import it otherwise
scrubbed$lat <- as.double(scrubbed$lat) #will fix the one NA later on
scrubbed$long <- as.double(scrubbed$long)

#Fix some UFO shape data
library(car)
scrubbed$shape <- recode(scrubbed$shape, "'changing'='changed'")
scrubbed$shape <- recode(scrubbed$shape, "'delta'='triangle'")
scrubbed$shape <- recode(scrubbed$shape, "'round'='other'")
scrubbed$shape <- recode(scrubbed$shape, "'hexagon'='other'")
scrubbed$shape <- recode(scrubbed$shape, "'crescent'='other'")
scrubbed$shape <- recode(scrubbed$shape, "'dome'='other'")
scrubbed$shape <- recode(scrubbed$shape, "'flare'='flash'")
scrubbed$shape <- recode(scrubbed$shape, "'pyramid'='triangle'")
#table(scrubbed$shape)

#Change to uppercase / capitals
scrubbed$state <- toupper(scrubbed$state)
scrubbed$country <- toupper(scrubbed$country) 

#Fix some Country NA's
us_state_abbrev <- c("AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "DC", 
                     "FL", "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", 
                     "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", 
                     "OR", "MD", "MA", "MI", "MN", "MS", "MO", "PA", "RI", "SC", "SD", 
                     "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY")
#ifelse(is.na(scrubbed$country) & scrubbed$state %in% us_state_abbrev, "US", "")

#City cleanup #don't worry about cleaning this one
#there are &# characters and all the stuff in (brackets)
library(stringr) #hadley
#scrubbed$country2 <- substr(scrubbed$city, 
#                            str_locate("\(", scrubbed$city), 
#                            length(scrubbed$city)
#                            )

scrubbed$city <- tools::toTitleCase(scrubbed$city) #takes a bit of time to run
#tools::toTitleCase("demonstrating the title case")

#This solution works better to extract the stuff in (brackets)
if (!require("pacman")) install.packages("pacman")
pacman::p_load(qdapRegex)
scrubbed$other_country <- rm_round(scrubbed$city, extract = TRUE)
scrubbed$city <- rm_round(scrubbed$city, extract = FALSE) #overwrites the city

#ifelse(is.na(scrubbed$country), scrubbed$country2, scrubbed$country)

#clean up some NA's
scrubbed <- scrubbed %>%
  mutate(state = ifelse(is.na(state),"Unknown",state))
#clean up the one New Mexico missing latitude and country
scrubbed[c(43783), ]$country <- "US"
scrubbed[c(43783), ]$lat <- 34.5199
scrubbed[c(43783), ]$long <- 105.9378
#scrubbed <- scrubbed[-c(43783), ] # has a missing latitude and will cause problems


#Final Cleaning
scrubbed$id <- as.numeric( row.names(scrubbed) )
scrubbed$year <- as.numeric( format(scrubbed$datetime, '%Y') )
scrubbed$month <- as.character( format(scrubbed$datetime, '%b') ) #in the app, convert to as.factor
scrubbed$month_num <- as.numeric( format(scrubbed$datetime, '%m') )
scrubbed$weekday <- as.character( format(scrubbed$datetime, '%a') ) #in the app, convert to as.factor
scrubbed$day <- as.numeric( format(scrubbed$datetime, '%d') )
scrubbed$weekend <- as.character( ifelse(scrubbed$weekday %in% c("Fri", "Sat", "Sun"), "Weekend", "Week") ) #in the app, convert to as.factor

scrubbed$postyear <- as.numeric( format(scrubbed$datetime, '%Y') )
scrubbed$postmonth <- as.character( format(scrubbed$datetime, '%b') ) #in the app, convert to as.factor
scrubbed$postmonth_num <- as.numeric( format(scrubbed$datetime, '%m') ) 
scrubbed$postweekday <- as.character( format(scrubbed$datetime, '%a') ) #in the app, convert to as.factor
scrubbed$postday <- as.numeric( format(scrubbed$datetime, '%d') )
scrubbed$postweekend <- as.character( ifelse(scrubbed$postweekday %in% c("Fri", "Sat", "Sun"), "Weekend", "Week") ) #in the app, convert to as.factor

scrubbed$comments <- gsub("&#[a-z0-9][a-z0-9]", '', scrubbed$comments)
scrubbed$comments <- gsub("&quot;", '', scrubbed$comments)

scrubbed$shape <- as.character(scrubbed$shape) #in the app, convert to as.factor
scrubbed$state <- as.character(scrubbed$state) #in the app, convert to as.factor
scrubbed$country <- as.character(scrubbed$country) #in the app, convert to as.factor

#scrubbed <- scrubbed[, -scrubbed$country2] #keep in

#anything greater than 73800 seconds(2.5 hours) gets into the days
scrubbed$minutes <- ifelse(scrubbed$seconds <= 73800, round(scrubbed$seconds/60, digits=1), NA )
#scrubbed$hours <- ifelse(scrubbed$seconds > 73800, round(scrubbed$seconds/60/60, digits=1), NA)
#scrubbed$days <- ifelse(scrubbed$seconds > 73800, round(scrubbed$seconds/60/60/24, digits=1), NA)

scrubbed$duration_descr <- NA #maybe set this to unknown
scrubbed$duration_descr[scrubbed$seconds <= 5] <- "Less than 5 seconds"
scrubbed$duration_descr[scrubbed$seconds > 5 & scrubbed$seconds <=30] <- "5 seconds to less than 30 seconds"
scrubbed$duration_descr[scrubbed$seconds > 30 & scrubbed$seconds <=60] <- "30 seconds to less than 1 minute"
scrubbed$duration_descr[scrubbed$seconds > 60 & scrubbed$seconds <=300] <- "1 minute to less than 5 minutes"
scrubbed$duration_descr[scrubbed$seconds > 300 & scrubbed$seconds <=600] <- "5 minute to less than 10 minutes"
scrubbed$duration_descr[scrubbed$seconds > 600 & scrubbed$seconds <=1800] <- "10 minutes to less than 30 minutes"
scrubbed$duration_descr[scrubbed$seconds > 1000 & scrubbed$seconds <=3600] <- "30 minutes to less than 1 hour"
scrubbed$duration_descr[scrubbed$seconds > 3600 & scrubbed$seconds <=86400] <- "1 hour to less than 24 hours"
scrubbed$duration_descr[scrubbed$seconds > 86400] <- "Greater than 24 hours"
scrubbed$duration_descr[is.na(scrubbed$seconds)] <- "Unknown"



#View(scrubbed %>% filter(duration_descr == "Unknown"))

#View(scrubbed)
saveRDS(scrubbed, "data/scrubbed.rdata")

readRDS("data/scrubbed.rdata")




############### Messing around







#scrubbed %>% filter(datetime >= "1980-1-1" & datetime <= "1981-1-1") %>% select(datetime)


#lbl_htmlblock <- c("<b>Shape: </b>", scrubbed[i,]$shape,"</br>", 
#           "<b>Date: </b>", scrubbed[i,]$month, scrubbed[i,]$day, scrubbed[i,]$year, "</br>",
#           "<b>Duration: </b>", scrubbed[i,]$duration,"</br>",
#           "<b>Location: </b>", scrubbed[i,]$city, scrubbed[i,]$state, scrubbed[i,]$country, scrubbed[i,]$other_country, "</br>",
#           "<b>Comment: </b>", scrubbed[i,]$comments,"</br>")

#this takes awhile to run
result <- sapply(1:nrow(scrubbed), function(i) paste("<b>Shape: </b>", scrubbed[i,]$shape,"</br>", 
           "<b>Date: </b>", scrubbed[i,]$month, scrubbed[i,]$day, scrubbed[i,]$year, "</br>",
           "<b>Duration: </b>", scrubbed[i,]$duration,"</br>",
           "<b>Location: </b>", scrubbed[i,]$city, scrubbed[i,]$state, scrubbed[i,]$country, scrubbed[i,]$other_country, "</br>",
           "<b>Comment: </b>", scrubbed[i,]$comments,"</br>", 
            collapse=""))
head(result)
length(result)
df2 <- as.data.frame(result)
df1 <- scrubbed
df1$lbl_htmlblock <- result

scrubbed$lbl_htmlblock <- result




max(!is.na(scrubbed$datetime))




##################


df1 <- scrubbed[1:50,]

df1$duration_descr <- NA
df1$duration_descr[df1$seconds <= 5] <- "Less than 5 seconds"
df1$duration_descr[df1$seconds > 5 & df1$seconds <=30] <- "5 seconds to less than 30 seconds"
df1$duration_descr[df1$seconds > 30 & df1$seconds <=60] <- "30 seconds to less than 1 minute"
df1$duration_descr[df1$seconds > 60 & df1$seconds <=300] <- "1 minute to less than 5 minutes"
df1$duration_descr[df1$seconds > 300 & df1$seconds <=600] <- "5 minute to less than 10 minutes"
df1$duration_descr[df1$seconds > 600 & df1$seconds <=1800] <- "10 minutes to less than 30 minutes"
df1$duration_descr[df1$seconds > 1000 & df1$seconds <=3600] <- "30 minutes to less than 1 hour"
df1$duration_descr[df1$seconds > 3600 & df1$seconds <=86400] <- "1 hour to less than 24 hours"
df1$duration_descr[df1$seconds > 86400] <- "Greater than 24 hours"
df1$duration_descr[is.na(df1$seconds)] <- "Unknown"
df1$duration_descr


#build HTML block for maps
df1 <- df1 %>% mutate(htmlblock = paste("<b>Shape: </b>", shape,"</br>", 
                                "<b>Date: </b>", month, day, year, "</br>",
                                "<b>Duration: </b>", duration,"</br>",
                                "<b>Location: </b>", city, state, country, other_country, "</br>",
                                "<b>Comment: </b>", comments,"</br>", collapse=''
                                ))


blcki <- paste("<b>Shape: </b>", df1[i,]$shape,"</br>", 
          "<b>Date: </b>", df1[i,]$month, df1[i,]$day, df1[i,]$year, "</br>",
          "<b>Duration: </b>", df1[i,]$duration,"</br>",
          "<b>Location: </b>", df1[i,]$city, df1[i,]$state, df1[i,]$country, df1[i,]$other_country, "</br>",
          "<b>Comment: </b>", df1[i,]$comments,"</br>")


result <- sapply(1:50, function(i) paste("x ", df1[i,]$shape,df1[i,]$month, df1[i,]$day, df1[i,]$year, sep=""))
result

result <- sapply(1:50, function(i) paste(blcki, collapse=""))

result <- sapply(1:50, function(i) paste("<b>Shape: </b>", df1[i,]$shape,"</br>", 
                                         "<b>Date: </b>", df1[i,]$month, df1[i,]$day, df1[i,]$year, "</br>",
                                         "<b>Duration: </b>", df1[i,]$duration,"</br>",
                                         "<b>Location: </b>", df1[i,]$city, df1[i,]$state, df1[i,]$country, df1[i,]$other_country, "</br>",
                                         "<b>Comment: </b>", df1[i,]$comments,"</br>",
                                         collapse=""))

as.data.frame(result)

df2 <- apply(df1, 1, blck, collapse=''  ) 

df_args <- c(blck, collapse="")
do.call(paste, df_args)

f <- function(x) {
  one <- x[1]
  paste("<b>Shape: </b>", one,"</br>", sep=",")
}

df3 <- by(df1, 1:nrow(df1), f)
df3

df3 <- apply(df1, 1, f)


for(i in 1:nrow(df1)) {
  row <- df1[i,]
  paste("<b>Shape: </b>", row$shape,"</br>", sep=",")
}

df1$blah <- paste("<b>Shape: </b>", row$shape,"</br>", sep=",")

