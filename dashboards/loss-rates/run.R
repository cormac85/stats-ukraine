PORT <- 6296

shiny::runApp('dashboards/loss-rates', port = PORT)
browseURL(paste0("http://127.0.0.1:", PORT))
