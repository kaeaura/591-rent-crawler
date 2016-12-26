library(shiny)

discards.dir <- '../result/shinyoutput_discards'
if (!file.exists(discards.dir) || !file.info(discards.dir)$isdir)
	dir.create(discards.dir)

discards.fn.prefix <- 'shinyoutput_discards'

runApp("shinyapp")
