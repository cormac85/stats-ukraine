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
        infoBoxOutput("overview_date", width = 12),
        box(
          DT::dataTableOutput('overview_table'), width = 12
        )
      )
    ),
    
    tabItem(
      tabName = "personnel",
      fluidRow(
        box(
          dateRangeInput(
            inputId = "personnel_date_range", 
            label = "Date range:",
            start = "2022-02-24",
            min = "2022-02-24"
          ),
          width = 6
        ),
        box(
          plotOutput("personnel_plot"),
          width = 12
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
          title="Ukraine Ministry of Defense Data",
          DT::dataTableOutput('raw_table'), width = 12
        )
      )
    ),
    
    tabItem(
      tabName = "sources",
      fluidRow(
        box(
          title="Ukraine Ministry of Defense Data",
          tags$div(
            actionButton(
              "mod_data_link", 
              "Petro Ivaniuk",
              onclick ="window.open('https://github.com/PetroIvaniuk/2022-Ukraine-Russia-War-Dataset', '_blank')")
            ),
            width = 12
        )
      )
    )
    
  )
)