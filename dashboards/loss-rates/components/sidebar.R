###################
# sidebar.R
# 
# Create the sidebar menu options for the ui.
###################
sidebar <- dashboardSidebar(
  sidebarMenu(
    includeCSS(SIDEBAR_STYLE_FILE_PATH),
    menuItem("Personell", tabName = "dashboard", icon = icon("person-military-rifle")),
    menuItem("Equipment", tabName = "widgets", icon = icon("jet-fighter"))
  ),
  width = 350
)

