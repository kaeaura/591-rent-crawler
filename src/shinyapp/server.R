library(shiny)
library(ggplot2)
theme_set(theme_bw())

function(input, output, session) {

    # Filter data based on selections
	output$table <- DT::renderDataTable(DT::datatable(batch.res.data, options = list(pageLength=20)))

	# Functions
	table_selected <- reactive({
		ids <- input$table_rows_selected
		batch.res.data[ids,]
	})

	table_not_selected <- reactive({
		ids <- input$table_rows_selected
		batch.res.data[setdiff(1:nrow(batch.res.data), ids),]
	})

	wrtfun2<-reactive({
		if (!is.null(input$var1))
			setwd("../result")
		sink("outfile.txt")
		cat()
		sink()
	})

	# Interactive
	output$tableSelected <- DT::renderDataTable({
		DT::datatable(
					  table_selected(),
					  selection = list(mode = "multiple"),
					  caption = "Selected Rows from Original Data Table",
					  options = list(paging=F)
					  )
	})

	output$tableSelectedDone <- DT::renderDataTable({
		done <- DT::datatable(table_not_selected(), 
							  selection = list(mode = "multiple"),
							  caption = "Done discards",
							  options = list(paging=F))
		input$goButton
		done
		write.csv(done$x$data, file='../../result/shinyoutput.csv', row.names=F)
	})

	output$scatterPlot <- renderPlot({
		s <- input$table_rows_selected
		data <- batch.res.data
		g <- ggplot(data, aes(x=area, y=price)) + geom_point(size=3) + theme(text = element_text(family = 'STXihei'))
		if (length(s)) {
        	g <- g + geom_point(data = data[s,], colour='red', size=6)
		}
		g 
	})

}
