library(shiny)
library(ggplot2)
theme_set(theme_bw())

function(input, output, session) {

    # Filter data based on selections
	output$table <- DT::renderDataTable(DT::datatable(batch.res.data, options = list(pageLength=10)))

	table_selected <- reactive({
		ids <- input$table_rows_selected
		batch.res.data[ids,]
	})

	output$tableSelected <- DT::renderDataTable({
		DT::datatable(
					  table_selected(),
					  selection = list(mode = "multiple"),
					  caption = "Selected Rows from Original Data Table"
					  )
	})

	output$scatterPlot <- renderPlot({
		s <- input$table_rows_selected
		data <- batch.res.data
		g <- ggplot(data, aes(x=area, y=price, shape=section_name)) + geom_point(size=3)
		if (length(s)) {
        	g <- g + geom_point(data = data[s,], colour='red', size=6)
		}
		g
	})
}
