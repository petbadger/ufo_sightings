library(tm)
library(wordcloud)
library(memoise)
library(leaflet)
library(htmltools)
library(shiny)
library(shinyjs)
library(shinythemes)
library(dplyr)
library(DT)
library(SnowballC) #needs to be here for shiny apps to works

source("list.R")

scrubbed <- readRDS("scrubbed.rdata")


ufoIcon <- makeIcon(
  iconUrl = "ufo_icon.png",
  iconWidth = 25, iconHeight = 20,
  iconAnchorX = 12, iconAnchorY = 10
)
