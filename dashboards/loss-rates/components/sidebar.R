###################
# sidebar.R
# 
# Create the sidebar menu options for the ui.
###################
sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Overview", tabName = "overview", icon = icon("square-poll-vertical")),
    menuItem("Personnel", tabName = "personnel", icon = icon("person-military-rifle")),
    menuItem("Equipment", tabName = "equipment", icon = icon("jet-fighter")),
    menuItem("Raw Data", tabName = "raw", icon = icon("eye"))
  )
)

