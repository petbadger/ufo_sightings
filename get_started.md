## How to use this app

* This app initializes the Date Range to the most current year available in the data.
* Since the app limits to viewing 1 year at a time, the table() function was used to determine the maximum observations in any given year. This can be set as the limit for the observation slider.

UFO Sighting Data
---

An explanations of the data is available on [Github](https://github.com/planetsig/ufo-reports "Ufo Dataset") and on [Kaggle](https://www.kaggle.com/NUFORC/ufo-sightings "Ufo Sighting Kaggle Contest").

The data has been further refined with additional columns added for ease of building a Shiny App and for future data exploration.  See the [Github Project](https://github.com/petbadger) for more details.

Although there are many variables in the data, not all have been chosen for the user to filter on. 

Filters
---
There are four columns of filters. Each column can be quickly reset to default by clickig on the respective Reset buttons. As filters are selected, the UFO Sightings data set is filtered accordingly and resulting records up to the selected number of observations selected in the filter is displayed on the map.

These same filters also filter the data table on the Data tab as well as the comments used to build the word cloud image on the Wordcloud tab.



Map Tab
---
The map is based on R Leaflet. It reacts to widget selections/filtering.

Locations with many UFO sightings get grouped into a circle marker with a count of the observations it contains. Clicking on the circle marker expands.

A user can pan around the map using the left-click and drag. If at any time there is difficulty moving around the map, the Zoom to Fit button will reset the view to contain all the mapped points.


Data Tab
---
The data table will show the data according to the filters. There are no "interactions" between the table and the map.

A useful feature of the data table is to filter comments based on words of interest. For example, the word "Orange" actually appears often.

Note that the *comments* field appears to be truncated at the data source. 


Wordcloud Tab
---
The wordcloud is just a quick way of viewing which words in the comments data are used more frequently.

The wordcloud is not built reactively since the processing of comments could be intensive. It will load the first time, but once the user filters the application, they must push the Build Wordcloud button. 



### See the About section tab for more details and list of improvements.


