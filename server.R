library(ggplot2)
theme_set(theme_bw())

source('acquire.R')

function(input, output, session) {

    data <- reactivePoll(1000, session,
                         checkFunc = function() {
                             if (file.exists(crawler.file))
                                 file.info(crawler.file)$mtime[1]
                             else
                                 ""
                         },
                         valueFunc = function() {
                             read.csv(crawler.file)
                         })

	# Functions
	table_selected <- reactive({
		ids <- input$table_rows_selected
		data()[ids,]
	})

	table_not_selected <- reactive({
		ids <- input$table_rows_selected
		collect[setdiff(1:nrow(collect), ids),]
	})

	rtext <- eventReactive(input$goButton, { 
		sprintf("Updated, %d records remained", nrow(collect))
	})

	# Interactive
	# candaidates
	output$table <- DT::renderDataTable({
        DT::datatable(data(), escape = FALSE, options = list(pageLength=5))
    })

	# preview
	output$tableSelected <- DT::renderDataTable({
		DT::datatable(table_selected(),
					  selection = list(mode = "multiple"),
                      escape = FALSE,
					  caption = "Selected Rows from Original Data Table",
					  options = list(paging=F))
	})
	# update
	output$tableSelectedDone <- DT::renderDataTable({
		done <- DT::datatable(table_selected(), 
							  selection = list(mode = "multiple"),
							  caption = "Done discards",
							  options = list(paging=F))

		# trigger the button
		input$goButton
		discard.ids <- done$x$data$id

		# update the data()
		data() <<- dplyr::filter(data(), !(id %in% discard.ids))

		# output the discard records
		write.csv(done$x$data,
				  file = file.path("..",
								   discards.dir,
								   sprintf("%s %s.csv", discards.fn.prefix, Sys.time())),
				  row.names = F)
	})

	output$scatterPlot <- renderPlot({
		s <- input$table_rows_selected
		pdata <- data()
		g <- ggplot(pdata, aes(x=area, y=price)) + geom_point(size=3) + theme(text = element_text(family = 'STXihei'))
		if (length(s)) {
        	g <- g + geom_point(data = data[s,], colour='red', size=6)
		}
		g 
	})

	output$responseText <- renderText({
		rtext()
	})

}
