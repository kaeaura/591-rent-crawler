# Load the ggplot2 package which provides
# the 'mpg' dataset.
library(ggplot2)

fluidPage(
  titlePanel("591 Rent candidates"),

  # Create a new Row in the UI for selectInputs
  fluidRow(
    column(4,
        selectInput("section",
                    "Section Name:",
                    c("All",
                      unique(as.character(batch.res.data$section_name))))
    ),
    column(4,
        selectInput("region",
                    "Region Name:",
                    c("All",
                      unique(as.character(batch.res.data$region_name))))
    )
  ),

  # Create a new row for the table.
  fluidRow(
    DT::dataTableOutput("table")
  ),

  fluidRow(
	plotOutput("scatterPlot")
  )
)
