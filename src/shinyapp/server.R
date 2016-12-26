library(ggplot2)
theme_set(theme_bw())

function(input, output, session) {

    # Filter data based on selections
	output$table <- DT::renderDataTable(DT::datatable(batch.res.data, options = list(pageLength=10)))

	# Functions
	table_selected <- reactive({
		ids <- input$table_rows_selected
		batch.res.data[ids,]
	})

	table_not_selected <- reactive({
		ids <- input$table_rows_selected
		batch.res.data[setdiff(1:nrow(batch.res.data), ids),]
	})

	rtext <- eventReactive(input$goButton, { 
		sprintf("Updated, %d records remained", nrow(batch.res.data))
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
		done <- DT::datatable(table_selected(), 
							  selection = list(mode = "multiple"),
							  caption = "Done discards",
							  options = list(paging=F))

		# trigger the button
		input$goButton
		discard.ids <- done$x$data$id

		# update the batch.res.data
		batch.res.data <<- dplyr::filter(batch.res.data, !(id %in% discard.ids))

		# output the discard records
		write.csv(done$x$data,
				  file = file.path("..",
								   discards.dir,
								   sprintf("%s %s.csv", discards.fn.prefix, Sys.time())),
				  row.names = F)
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

	output$responseText <- renderText({
		rtext()
	})

}
