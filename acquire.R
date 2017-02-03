VERSION = '0.0.1'

library('GetoptLong')
library('httr')
suppressPackageStartupMessages(library('jsonlite'))
suppressPackageStartupMessages(library('xml2'))
suppressPackageStartupMessages(library('rvest'))
suppressPackageStartupMessages(library('magrittr'))
suppressPackageStartupMessages(library('plyr'))
suppressPackageStartupMessages(library('dplyr'))

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

# query parameter
desired_section <- c("10", "11")
desired_region <- 1

desired_rent <- "2,3,4"
# rent price: 
#rentpriceMore 租金
# 2: 5k - 10k
# 3: 10k - 20k
# 4: 20k - 30k
desired_area <- "10,30"
desired_sex <- 0

# TO BE MODIFIED
GetoptLong(
		   "desired_section|section|s=s", "desired section, default by 10 and 11",
		   "desired_region|region|r=i", "region, default = 1",
		   "desired_area|area|a=s", "area, default = '10,30'",
		   "desired_rent|rent|r=s", "rent, default='2,3,4', indicating $5k--$30k",
		   "desired_sex|sex|x=s", "sex, default=0",
		   "verbose", "print messages",
		   foot = "Please contact kaeaura@gmail.com for comments"
)

qqcat("desired_section=@{desired_section}\n")
#qqcat("desired_region=@{desired_region}")
#qqcat("desired_area=@{desired_area}")
#qqcat("desired_rent=@{desired_rent}")
#qqcat("desired_sex=@{desired_sex}")

stopifnot(1==2)
collection <- lapply(desired_section,
                     function(sc) {
                        message('acquring section = ', sc)
                        batch.query(url = target.url,
								    section = sc,
									region = desired_region,
									area = desired_area,
									rentprice.more = desired_rent,
									sex = desired_sex,
									) %>%
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
