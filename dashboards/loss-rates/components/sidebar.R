###################
# sidebar.R
# 
# Create the sidebar menu options for the ui.
###################
sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Loss Summary", tabName = "overview", icon = icon("square-poll-vertical")),
    menuItem("Current Week", tabName = "current_week", icon = icon("burst")),
    menuItem("Personnel", tabName = "personnel", icon = icon("person-military-rifle")),
    menuItem("Equipment", tabName = "equipment", icon = icon("jet-fighter")),
    menuItem("Oryx", tabName = "oryx", icon = icon("user-secret")),
    menuItem("Raw Data", tabName = "raw", icon = icon("eye")),
    menuItem("Sources", tabName = "sources", icon = icon("asterisk"))
  )
)

