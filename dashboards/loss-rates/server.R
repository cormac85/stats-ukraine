server <- function(input, output, session) {
  
  output$raw_table <- DT::renderDataTable(
    create_downloadable_table(MOD_LOSSES_DF)
  )
  
  output$overview_table <- DT::renderDataTable(
    create_downloadable_table(MOD_LOSSES_DF)
  )
  
}