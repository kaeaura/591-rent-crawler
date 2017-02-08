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
crawler.file <- file.path(crawler.dir, 'candidates_cached.csv')
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
desired_rent <- c("2", "3", "4")
# rent price: 
#rentpriceMore 租金
# 2: 5k - 10k
# 3: 10k - 20k
# 4: 20k - 30k
desired_area_range <- c(10, 30)
desired_gender_rest <- 0

GetoptLong(
		   "desired_section|section|s=s@", "desired sections, default by 10 and 11 (i.e. -s 10 -s 11)",
		   "desired_region|region|r=i", "desired sections region, default = 1",
		   "desired_area_range|area|a=s{2}", "area range, 10, 20, 30, 40. default = '10,30'",
		   "desired_rent|rent|r=s@", "rent, default='2,3,4', indicating $5k--$30k",
		   "desired_gender_rest|gender|g=s", "gender restriction where 0 = none, 1 = male only, 2 = female only, default = 0",
		   "verbose", "print messages",
		   foot = "Please contact kaeaura@gmail.com for comments"
)

if (verbose) {
	qqcat("desired_section=@{desired_section}\n--\n")
	qqcat("desired_region=@{desired_region}\n--\n")
	qqcat("desired_area_range=@{desired_area_range}\n--\n")
	qqcat("desired_rent=@{desired_rent}\n--\n")
	qqcat("desired_gender_rest=@{desired_gender_rest}\n--\n")
}

collection <- lapply(desired_section,
					 function(sc) {
						 if (verbose) message('acquring section = ', sc)
						 batch.query(url = target.url,
									 section = sc,
									 region = desired_region,
									 area = paste(desired_area_range, collapse=","),
									 rentprice.more = paste(desired_rent, collapse=","),
									 sex = desired_gender_rest
									 ) %>%
						 extract_content() 
					 }) %>%
			 discard.null.elt() %>% 
			 ldply()

message('We crawl ', nrow(collection), ' records from 591 website.')

# discarding unwanted cases
discards.fl <- list.files(discards.dir, '.csv', full.name=T)
if (length(discards.fl)) {
    discards <- lapply(discards.fl, read.csv) %>% ldply() %>% distinct(id, .keep_all=T)
    message('there are ', length(unique(discards$id)),  ' discards')
    collection <- dplyr::filter(collection, !(id %in% discards$id))
    message('After filtering discarded items, it leaves ', nrow(collection), ' records')
}

# update news
if (file.exists(crawler.file)) {
    previous.collection <- read.csv(crawler.file)
} else {
    previous.collection <- collection[numeric(0),]
}

add <- setdiff(collection$post_id, previous.collection$post_id)
remove <- setdiff(previous.collection$post_id, collection$post_id)
update <- intersect(previous.collection$post_id, collection$post_id)

slack.message <- sprintf('Query complete at %s.\n Among the acquired posts, there are %d new posts, %d old posts, and %d updated posts',
                          Sys.time(), length(add), length(remove), length(update))
slackme(slack.message)
if (length(add)) slackme(capture.output(print(dplyr::filter(collection, post_id %in% add))))

# show the latest updates
slack.message2 <- collection %>% dplyr::select(posttime, fulladdress, url) %>% head(3) %>% print() %>% capture.output() %>% paste(collapse="\n")
slackme(slack.message2)

# update new posts
write.csv(collection, file = crawler.file, row.names = F)
