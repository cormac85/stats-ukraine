server <- function(input, output, session) {
  
  
  output$personnel_table <- DT::renderDataTable(
    MOD_LOSSES_DF, options = list(scrollX = TRUE)
  )
  
}