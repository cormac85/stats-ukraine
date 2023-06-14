server <- function(input, output, session) {
  
  ################
  # Loss Summary #
  ###############
  output$overview_table <- DT::renderDataTable(
    OVERVIEW_LOSSES_DF |> 
      filter(reverse_week_start_date == max(reverse_week_start_date)) |> 
      select(-reverse_week_start_date, -date) |> 
      janitor::clean_names(case = "title") |> 
      add_styling_to_weekly_losses() |> 
      create_downloadable_table()
  )
  
  output$overview_date <- renderInfoBox({
    infoBox(
      "Updated On:", OVERVIEW_DATE, icon = icon("calendar-days"), color = "light-blue"
    )
  })
  
  output$all_loss_types_moving_average_plot <- shiny::renderPlot({
    MOD_LOSSES_DF |> 
      enrich_daily_losses() |> 
      reshape_moving_averages() |> 
      map_loss_types_for_display() |> 
      plot_all_loss_moving_average(window_len = 7)
  })
  
  
  #############
  # Personnel #
  #############
  rendered_personnel_df <- reactive({
    filter(
      MOD_LOSSES_DF,
      between(
        date, 
        input$personnel_date_range[1],
        input$personnel_date_range[2]
      )
    )
  })
  
  output$personnel_plot <- renderPlot({
    rendered_personnel_df() |> 
      enrich_daily_losses() |> 
      calculate_weekly_losses() |> 
      weekly_personnel_plot()
  })
  
  output$DateRange <- renderText({
    # make sure end date later than start date
    validate(
      need(input$dates[2] > input$dates[1], "end date is earlier than start date"
      )
    )
  })
  
  
  ############
  # Raw Data #
  ############
  output$raw_table <- DT::renderDataTable(
    MOD_LOSSES_DF |> 
      janitor::clean_names(case = "title") |> 
      create_downloadable_table()
  )
  
}