library('httr')
library('jsonlite')
library('xml2')
library('plyr')
library('magrittr')
library('rvest')
library('dplyr')

source('utility.R')

# global var
target.url <- 'https://rent.591.com.tw/home/search/rsList'
crawler.dir <- './result/crawler'
discards.dir <- './result/shinyoutput_discards'
discards.fn.prefix <- 'shinyoutput_discards'
# create the directory
if (!file.exists(crawler.dir) || !file.info(crawler.dir)$isdir)
	dir.create(crawler.dir, recursive = T)
if (!file.exists(discards.dir) || !file.info(discards.dir)$isdir)
	dir.create(discards.dir)

# query
section.candidates <- c("10", "11")
collection <- lapply(section.candidates,
                     function(sc) {
                        message('acquring section = ', sc)
                        batch.query(url = target.url, section= sc) %>%
                        extract_content() 
                    }) %>% 
               discard.null.elt() %>%
               ldply()

# discarding unwanted cases
discards.fl <- list.files(discards.dir, '.csv', full.name=T)
if (length(discards.fl)) {
    discards <- lapply(discards.fl, read.csv) %>% ldply() %>% distinct(id, .keep_all=T)
    message('we crawl ', nrow(collection), ' records from 591.')
    message('there are ', length(unique(discards$id)),  ' discards')
    collection <- dplyr::filter(collection, !(id %in% discards$id))
    message('It leaves ', nrow(collection), ' records after this carwl')
}

# output file
if (F) {
	write.csv(data,
			  file=file.path(crawler.dir, sprintf('591_candidates_%s.csv', Sys.time())),
			  row.names=F)
}
