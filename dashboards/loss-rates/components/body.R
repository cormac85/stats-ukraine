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
        infoBoxOutput("overview_date", width = 6),
        box(    
          shinyWidgets::pickerInput(
            inputId = "loss_type_input",
            label = "Select Loss Type",
            choices = unique(OVERVIEW_LOSSES_DF$loss_type),
            multiple = TRUE,
            options = list(`actions-box` = TRUE)
          ),
          height = 90)
      ),
      fluidPage(
        column(
          width=6,
          box(
            DT::dataTableOutput('overview_table'), 
            width = 12, 
            height = SUMMARY_PAGE_BOX_HEIGHT + 23
          )
        ),
        column(
          width=6,
          box(
            shiny::plotOutput(
              "all_loss_types_moving_average_plot",
              height=SUMMARY_PAGE_BOX_HEIGHT
            ),
            width = 12
          )
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
          plotly::plotlyOutput("personnel_plot"),
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