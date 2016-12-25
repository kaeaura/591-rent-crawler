library('httr')
library('jsonlite')
library('xml2')
library('xmlview')
library('magrittr')
library('rvest')
library('dplyr')

source('utility.R')

rent.query <- function(url, is.new.list=1, type=1, kind=0, search.type=1, region=1, section="4,10,11,27", kind2=1, rentprice.more="2,3,4", area="10,30", sex="0",
                       first.row=NULL, total.rows=NULL) {
    # test.run
    # https://rent.591.com.tw/home/search/rsList?is_new_list=1&type=1&kind=0&searchtype=1&region=1&section=10&kind=1&rentpriceMore=2,3&sex=0

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

# global var
target.url <- 'https://rent.591.com.tw/home/search/rsList'
output.dir <- '../result/'

# inital query
init.res <- rent.query(url=target.url)
init.status <- httr::status_code(init.res)
init.cont <- httr::content(init.res, "text") %>% jsonlite::fromJSON()

# there is a magic number here. it may change in furture version(?)
# extract the total record
total.records <- init.cont$data$page %>% 
                 read_html() %>% 
                 html_nodes('span') %>% 
                 extract2(5) %>% 
                 html_text() %>% 
                 as.numeric()

# crawl the results
step.width <- 30
first.rows <- seq(from=0, to=total.records, by=step.width)

batch.res <- lapply(first.rows,
                    function(fr) {
                        message(sprintf('row.index: %d, total: %d', fr, total.records))
                        r <- rent.query(url=target.url, first.row=fr, total.rows=total.records)
                        message(sprintf('status code: %d', status_code(r)))
                        return(list(status=status_code(r), parsed.content=content(r, "text") %>% jsonlite::fromJSON()))
                    })

batch.res.data <- lapply(batch.res, function(res) { res$parsed.content$data$data }) %>% 
                  ldply(.id='page.index') %>% 
                  dplyr::filter(closed == 0) %>% 
                  dplyr::mutate(url = get.detail.url(id),
                                posttime.digit = extract.digits(posttime) %>% as.integer(),
                                posttime.unit = extract.strings(posttime) %>% factor(levels=posttime.units.levels)) %>%
                  dplyr::select(posttime, posttime.digit, posttime.unit, browsenum, room, area, price, region_name, section_name, fulladdress, url,
                                id, user_id, post_id, checkstatus, status, closed) %>%
                  dplyr::distinct(id, .keep_all=T) %>%
                  dplyr::arrange(posttime.unit, posttime.digit)

# store the result and upload to google drive
file.name <- file.path(output.dir, sprintf('591_candidates_%s.csv', Sys.time() %>% strftime('%F %H:%M')))
write.csv(batch.res.data, file=file.name, row.names=F)

# register the key
#gs_upload(file.name, sheet_title='file.name')

#g <- gs_new('candidates', ws_title='591Candidates', input=batch.res.data, trim=T, verbose=F)
# Key: 1_eDR9hmCP85AHQpr2RqU9J7ji3O2_s6eYzJdlLQLIQs
# Alternate key: 1_eDR9hmCP85AHQpr2RqU9J7ji3O2_s6eYzJdlLQLIQs
# Browser URL: https://docs.google.com/spreadsheets/d/1_eDR9hmCP85AHQpr2RqU9J7ji3O2_s6eYzJdlLQLIQs/
