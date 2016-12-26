library(ggplot2)
theme_set(theme_bw())

function(input, output, session) {

    # Filter data based on selections
	output$table <- DT::renderDataTable(DT::datatable(collection, options = list(pageLength=10)))

	# Functions
	table_selected <- reactive({
		ids <- input$table_rows_selected
		collection[ids,]
	})

	table_not_selected <- reactive({
		ids <- input$table_rows_selected
		collection[setdiff(1:nrow(collection), ids),]
	})

	rtext <- eventReactive(input$goButton, { 
		sprintf("Updated, %d records remained", nrow(collection))
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

		# update the collection
		collection <<- dplyr::filter(collection, !(id %in% discard.ids))

		# output the discard records
		write.csv(done$x$data,
				  file = file.path("..",
								   discards.dir,
								   sprintf("%s %s.csv", discards.fn.prefix, Sys.time())),
				  row.names = F)
	})

	output$scatterPlot <- renderPlot({
		s <- input$table_rows_selected
		data <- collection
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
