## This app was built as the final assignment for the Coursera Data Products class (Data Science Certification)

__Please don't plagiarize this work. You will only cheat yourself.__

### Contact Info
Jared Prins aka PetBadger 
https://github.com/petbadger

### Notes about this Application
* This app initializes the Date Range to the most current year available in the data.
* The wordcloud is not built reactively since the processing of comments could be intensive. 



### Kaggle contest

Part of the inspiration for this app was a [Kaggle contest using the Ufo sightings data](https://www.kaggle.com/NUFORC/ufo-sightings "Ufo Sighting Kaggle Contest").  

I thought that perhaps this app could be used someone explore the data set. 

### The Ufo Dataset

A big thank you to [Sigmond Axel](https://github.com/planetsig/ufo-reports "Ufo Dataset") for scraping, geolocating and time standardizing the NUFORC data. Perhaps work like Sigmonds, those on Kaggle, and this Shiny App will demonstrate to NUFORC the value of working with the data science community.  NUFORC, please consider opening your data under an open data license. 

The *comments* field appears to be truncated at the source. Phooey.


### List of improvements

This was really first crack at building an R Shiny Application. There is a LOT of room for improvement.  But here is a list of things that come to mind.

#### Minor

* the theme causes the colour of the date range widget to be difficult to read. 
* there is still some minor data cleanup with Country. I was able to extract some additional Country information from the City field, and added it as other_country.  
* The field seconds can also be cleaned up further. Where seconds = NA, the duration field is usually in seconds. Some small rules that search for the string "sec" and extracting the number can fill in the missing seconds.
* some more validation is likely needed. I am sure there are areas the app will break.
* some interested patterns might be detected when cross tabbing variables. For example, are there more sightings on weekends? Do certain sightings happen at certain times of the day? Is sighting shape and location or date related to eachother?  Are there any common themes with latitude and longitude? 
* Add more general validation, if necessary. Only have it for empty data set right now.
* Originally I had a date range selection, but there is so much data that leaflet or Shiny crashes. I limited it to 5 years. Not sure if this is as user friendly as it could be. And perhaps there is a better way to load a lot of data?
* Would like to get icons for each Ufo shape. It's hard to find good shapes!
* Size of wordcloud needs to be changed so it fits all words. Currently if some words are too big, it won't be plotted. Example error: __Warning in wordcloud(corp, scale = c(10, 1), max.words = 30, random.order = FALSE,  :
  1989 could not be fit on page. It will not be plotted.__ 
* Some years have no data. So the Year slider returns no Map. Could maybe add a check that if the dataset is empty, it recursively checks the year, adding one year, until the data set is not empty.  But this only happens in the first few years of the data.


#### Major

* possibly the corpus of comments could be created once at the start of the app
* There are a lot of observations in this data which might have performance issues.
* Pull in population data to see how population density relates to sightings. Perhaps even geographic attribute data could be brought in too (e.g. mountains, water bodies, road networks).


#### Massive

Although it would be a massive undertaking, I don't see why a YAML type of configuration file couldn't drive the automated generation of a basic Shiny App from a data source for the purposes of exploration. Much like Ruby on Rails scaffholding or Python's Django.

The configuration file would have to: 
* Point to the data, the app theme, and other setup items
* Specify layout (e.g. Tabs, navigation)
* Perhaps point to some R scripts that need to be run (during certain stages of the app)
* Specify validation messages, headings
* Specify the desired widget/variable pairs, along with settings

"Boilerplate" code would be needed. A command would simply insert the configuration information into the boilerplate code, and export the result to the necessary files.

Note that there are some Google hits for "Boilerplate R Shiny".  There is also a book "Web Application Development with R Using Shiny" which might do something similar. It looks like it somehow uses Markdown to generate the app.

