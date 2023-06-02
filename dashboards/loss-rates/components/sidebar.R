###################
# sidebar.R
# 
# Create the sidebar menu options for the ui.
###################
sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Personnel", tabName = "personnel", icon = icon("person-military-rifle")),
    menuItem("Equipment", tabName = "equipment", icon = icon("jet-fighter"))
  ),
  width = LOGO_WIDTH_PX
)

