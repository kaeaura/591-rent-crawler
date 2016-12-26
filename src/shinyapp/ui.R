# Load the ggplot2 package which provides
# the 'mpg' dataset.
library(ggplot2)

fluidPage(

  navbarPage("Rent candidates", 
	title = "591 Crawler",
	tabPanel("Candidates", DT::dataTableOutput("table")),
	tabPanel("Preview", DT::dataTableOutput("tableSelected")), 
	tabPanel("Summary Plot", plotOutput("scatterPlot")),
	tabPanel("Update",
			 verbatimTextOutput("responseText"),
			 actionButton("goButton", "Insert discards"),
			 br(),
			 DT::dataTableOutput("tableSelectedDone"))
  )
)
