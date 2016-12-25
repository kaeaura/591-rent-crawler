
posttime.units.levels <- c('分鐘內', '小時內', '昨日', '天前')

get.detail.url <- function(url.id) {
    sprintf("https://rent.591.com.tw/rent-detail-%s.html", url.id)
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
