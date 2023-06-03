###################
# body.R
# 
# Create the body for the ui. 
# If you had multiple tabs, you could split those into their own
# components as well.
###################
body <- dashboardBody(
  includeCSS(HEADER_STYLE_FILE_PATH),
  includeCSS(SIDEBAR_STYLE_FILE_PATH),
  includeCSS(BODY_STYLE_FILE_PATH),
  tabItems(
    
    tabItem(
      tabName = "overview",
      fluidRow(
        box(
          DT::dataTableOutput('overview_table'), width = 12
        )
      )
    ),
    
    tabItem(
      tabName = "personnel",
      fluidRow(
        box(
          tags$div(
            tags$i(class = "fa-solid fa-person-digging", style = "font-size:6rem"),
            tags$span("Under Construction!")
          )
        )
      )
    ),
    
    tabItem(
      tabName = "equipment",
      fluidRow(
        box(
          tags$div(
            tags$i(class = "fa-solid fa-person", style = "font-size:6rem"),
            tags$span("Under Construction!")
          )
        )
      )
    ),
    
    tabItem(
      tabName = "raw",
      fluidRow(
        box(
          DT::dataTableOutput('raw_table'), width = 12
        )
      )
    )
  )
)