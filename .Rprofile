options(SLACK_MMNET_POSTURL = Sys.getenv("SLACK_MMNET_POSTURL"))

# slack notification
slackme <- function(msg, channel=NULL) {
    hostname <- system("hostname", intern = TRUE)
    msg <- sprintf("%s (%s) \n```\n%s\n```", hostname, Sys.time(), msg)
    if (is.null(channel)) {
        httr::POST(url = sprintf("https://hooks.slack.com/services/%s", getOption("SLACK_MMNET_POSTURL")), encode = "json", body = list(text = msg))
    } else {
        httr::POST(url = sprintf("https://hooks.slack.com/services/%s", getOption("SLACK_MMNET_POSTURL")), encode = "json", body = list(text = msg, channel=channel))
    }
}
