library(shiny)
library(ggplot2)
theme_set(theme_bw())

function(input, output) {

    # Filter data based on selections
    output$table <- DT::renderDataTable(DT::datatable({
        data <- batch.res.data
        if (input$section != "All") {
            data <- data[data$section_name == input$section,]
        }
        if (input$region != "All") {
            data <- data[data$region_name == input$cyl,]
        }
        data
    }))

	output$scatterPlot <- renderPlot({
		s <- input$table_rows_selected
		message(s)
		data <- batch.res.data
		g <- ggplot(data, aes(x=area, y=price, shape=section_name)) + geom_point(size=3)
		if (length(s)) {
        	g <- g + geom_point(data = data[s,], colour='red', size=6)
		}
		g
	})
}
