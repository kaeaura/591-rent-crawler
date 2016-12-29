library(shiny)

source('acquire.R')
runApp("shinyapp", port=8080, host="0.0.0.0")
