
posttime.units.levels <- c('分鐘內', '小時內', '昨日', '天前')

get.detail.url <- function(url.id) {
    # complete the acquired URL
    full.url <- sprintf("https://rent.591.com.tw/rent-detail-%s.html", url.id)
    sprintf("<a href='%s' target='_blank'>%s</a>", full.url, full.url)
}

extract.digits <- function(s, do.strip=F) {
    # get the digit part if do.strip = FALSE
    # else, get the non-digit part
    stopifnot(class(s) == 'character')
    if (do.strip) {
        return(gsub("[0-9]", "", s))
    } else {
        return(gsub("[^0-9]", "", s))
    }
}

discard.null.elt <- function(l) {
    l[!sapply(l, is.null)]
}

# 591 query api
# return
rent.query <- function(url, is.new.list=1, type=1, kind=0, search.type=1, region=1, section="4", kind2=1, rentprice.more="2,3,4", area="10,30", sex="0",
                       first.row=NULL, total.rows=NULL) {
    # test cases
    # test.run
	# 台北
    # https://rent.591.com.tw/home/search/rsList?is_new_list=1&type=1&kind=0&searchtype=1&region=1&section=10&kind=1&rentpriceMore=2,3&sex=0
	# 新北 汐止
	# https://rent.591.com.tw/home/search/rsList?is_new_list=1&type=1&kind=0&searchtype=1&region=1&section=27&kind=1&rentpriceMore=2,3&sex=0&area=20,30

    # region

    # section 鄉鎮
    # 10: 內湖
    # 4: 松山
    # 11: 南港區
    # 27: 汐止

    #rentpriceMore 租金
    # 2: 5k - 10k
    # 3: 10k - 20k
    # 4: 20k - 30k

    # area 坪數
    # 20,30: 20坪到30坪

    #sex 性別
    # 0: 不限

    if (is.null(first.row) && is.null(total.rows)) {
        GET(url = url,
            query = list(is_new_list=is.new.list,
                         type=type,
                         kind=kind,
                         searchtype=search.type,
                         region=1,
                         section=section, # 鄉鎮
                         kind=kind2,
                         rentpriceMore=rentprice.more,
                         area=area,
                         sex=sex))
    } else if (!is.null(first.row) && !is.null(total.rows)) {
        GET(url = url,
            query = list(is_new_list=is.new.list,
                         type=type,
                         kind=kind,
                         searchtype=search.type,
                         region=1,
                         section=section, # 鄉鎮
                         kind=kind2,
                         rentpriceMore=rentprice.more,
                         area=area,
                         sex=sex,
                         firstRow=first.row,
                         totalRows=total.rows))
    } else {
        message("Error: first row and total.rows should be set simultaneously")
        return(-1)
    }
                
}

#rent.query2 <- function(url, ) {
# httr issues: may not bring the headers correctly
# solution use RCurl to fix this issue

# success 新北市
#RCurl::getURL('https://rent.591.com.tw/home/search/rsList?is_new_list=1&type=1&kind=0&searchtype=1&region=1&section=27', httpheader = c('Accept-Language'='en-US,en;q=1.8,zh-TW;q=0.6,zh;q=0.4,ja;q=0.2', 'Accept-Encoding'='gzip, deflate, sdch, br', 'Accept'='text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8', 'user_agent'='Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36', 'Cookie'='urlJumpIp=3; urlJumpIpByTxt=%E6%96%B0%E5%8C%97%E5%B8%82;'))

# success 台北市
# RCurl::getURL('https://rent.591.com.tw/home/search/rsList?is_new_list=1&type=1&kind=0&searchtype=1&region=1&section=4', httpheader = c('Accept-Language'='en-US,en;q=1.8,zh-TW;q=0.6,zh;q=0.4,ja;q=0.2', 'Accept-Encoding'='gzip, deflate, sdch, br', 'Accept'='text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8', 'user_agent'='Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36', 'Cookie'='urlJumpIp=1; urlJumpIpByTxt=%E5%8F%B0%E5%8C%97%E5%B8%82;'))

#}

batch.query <- function(url, is.new.list=1, type=1, kind=0, search.type=1, region=1, section="4,10,11,27", kind2=1, rentprice.more="2,3,4", area="10,30", sex="0", first.row=NULL, total.rows=NULL, each.query.row=30) {
    # this function launchs the initial query to get the total number of records, then get the rest.

	# inital query
	init.res <- rent.query(url=url,
						   is.new.list=is.new.list,
						   type=type,
						   kind=kind, 
						   search.type=search.type,
						   region=region,
						   section=section,
						   kind2=kind2,
						   rentprice.more=rentprice.more,
						   area=area,
						   sex=sex)

	init.status <- httr::status_code(init.res)
	init.cont <- httr::content(init.res, type="text", encoding="UTF-8") %>% jsonlite::fromJSON()

    # if no result returns, then break and get a null list
	if (is.null(init.cont$data$page)) {
		return(list(status_code=NULL, parsed.content=NULL))
	}
	
	# there is a magic number here. it may change in furture version(?)
	# extract the total record
	total.records <- init.cont$data$page %>% 
		read_html() %>% 
		html_nodes('span') %>% 
		extract2(5) %>% 
		html_text() %>% 
		as.numeric()

	# crawl the results
	batch.res <- lapply(seq(from=0, to=total.records, by=each.query.row),
						function(fr) {
							message(sprintf('row.index: %d, total: %d', fr, total.records))
							r <- rent.query(url=url,
											first.row=fr,
											total.rows=total.records,
											is.new.list=is.new.list,
											type=type,
											kind=kind, 
											search.type=search.type,
											region=region,
											section=section,
											kind2=kind2,
											rentprice.more=rentprice.more,
											area=area,
											sex=sex)
							message(sprintf('status code: %d', status_code(r)))
							return(list(status=status_code(r),
										parsed.content=content(r, type="text", encoding="UTF-8") %>% jsonlite::fromJSON()
								       )
								  )
						})

	if (any(sapply(batch.res, function(r) r$status) == F)) {
		message('Warning: crawling incomplete')
	}

	return(batch.res)
}

extract_content <- function(res) {
	data <- lapply(res, function(res) { res$parsed.content$data$data }) %>% discard.null.elt()

	if (length(data)) {
		data1 <- data %>% 
			ldply(.id='page.index') %>% 
			dplyr::filter(closed == 0, photoNum >= 1) %>% 
			dplyr::mutate(url = get.detail.url(id),
						  posttime.digit = extract.digits(posttime, do.strip=F) %>% as.integer(),
						  posttime.unit = extract.digits(posttime, do.strip=T) %>% factor(levels=posttime.units.levels),
                          price.per.area = as.integer(as.integer(gsub(",", "", price)) / as.numeric(area))) %>%
			dplyr::select(posttime, posttime.digit, posttime.unit, browsenum, room, area, price, price.per.area, region_name, section_name, fulladdress, url, id, user_id, post_id, checkstatus, status, closed) %>%
			dplyr::distinct(id, .keep_all=T) %>%
			dplyr::arrange(posttime.unit, posttime.digit)
		return(data1)
	} else {
		return(NULL)
	}
}
