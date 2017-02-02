
posttime.units.levels <- c('分鐘內', '小時內', '昨日', '天前')

get.detail.url <- function(url.id) {
    full.url <- sprintf("https://rent.591.com.tw/rent-detail-%s.html", url.id)
    sprintf("<a href='%s' target='_blank'>%s</a>", full.url, full.url)
}

extract.digits <- function(s) {
    stopifnot(class(s) == 'character')
    digit.part <- gsub('[^0-9]', "", s)
    return(digit.part)
}

extract.strings <- function(s) {
    stopifnot(class(s) == 'character')
    digit.part <- gsub('[0-9]', "", s)
    return(digit.part)
}

discard.null.elt <- function(l) {
    l[!sapply(l, is.null)]
}
