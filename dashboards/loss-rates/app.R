library(shiny)
library(shinydashboard)
library(DT)
library(janitor)
source(file.path(here::here(), 'ui.R'))
source(file.path(here::here(), 'server.R'))

shinyApp(ui, server)