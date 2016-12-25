
posttime_recg <- function(s) {
    stopifnot(class(s) == 'character')
    digit.part <- gsub('[^0-9]', "", s)
    return(digit.part)
}
