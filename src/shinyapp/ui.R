# Load the ggplot2 package which provides
# the 'mpg' dataset.
library(ggplot2)

fluidPage(

  navbarPage("Rent candidates", 
	title = "591 Crawler",
	tabPanel("Candidates", DT::dataTableOutput("table")),
	tabPanel("Discards", DT::dataTableOutput("tableSelected")), 
	tabPanel("Summary Plot", plotOutput("scatterPlot"))
  )
)
