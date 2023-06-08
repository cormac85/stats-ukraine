server <- function(input, output, session) {
  
  output$raw_table <- DT::renderDataTable(
    MOD_LOSSES_DF |> 
      janitor::clean_names(case = "title") |> 
      create_downloadable_table()
  )
  
  output$overview_table <- DT::renderDataTable(
    OVERVIEW_LOSSES_DF |> 
      filter(reverse_week_start_date == max(reverse_week_start_date)) |> 
      select(-reverse_week_start_date, -date) |> 
      janitor::clean_names(case = "title") |> 
      create_downloadable_table()
  )
  
  output$overview_date <- renderInfoBox({
    infoBox(
      "Updated On:", OVERVIEW_DATE, icon = icon("calendar-days"), color = "light-blue"
    )
  })
  
  output$personnel_plot <- renderPlot(
    MOD_LOSSES_DF |> 
      calculate_weekly_losses(format_loss_col = FALSE) |> 
      weekly_personnel_plot()
  )
  
}