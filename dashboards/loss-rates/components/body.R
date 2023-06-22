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
      fluidPage(
        width=12,
        box(    
          shinyWidgets::pickerInput(
            inputId = "loss_type_input",
            label = "Select Loss Type",
            choices = unique(OVERVIEW_LOSSES_DF$loss_type),
            multiple = TRUE,
            options = list(`actions-box` = TRUE)
          ),
          height = 90
        ),
        box(
          shiny::plotOutput(
            "all_loss_types_moving_average_plot",
            height=SUMMARY_PAGE_BOX_HEIGHT
          ),
          width = 12
          
        )
      )
    ),
    
    tabItem(
      tabName = "current_week",
      fluidPage(
        width=12,
        infoBoxOutput("overview_date", width = 12),
        box(
          DT::dataTableOutput('overview_table'), 
          width = 12, 
          height = SUMMARY_PAGE_BOX_HEIGHT + 23
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
          dateRangeInput(
            inputId = "equipment_date_range", 
            label = "Date range:",
            start = "2022-02-24",
            min = "2022-02-24"
          ),
          width = 6,
          height = 110
        ),
        box(    
          shinyWidgets::pickerInput(
              inputId = "equipment_loss_type",
              label = "Equipment Type", 
              choices = filter(
                LOSS_TYPE_MAP, loss_type != "personnel"
              )$loss_type_display
            )
          ,
          height = 110
        )
      ),
      fluidRow(
        box(
          plotly::plotlyOutput("equipment_plot"),
          width = 12
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