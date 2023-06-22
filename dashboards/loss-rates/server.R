server <- function(input, output, session) {
  
  ################
  # Loss Summary #
  ###############
  
  # Table
  output$overview_table <- DT::renderDataTable(
    OVERVIEW_LOSSES_DF |> 
      filter(reverse_week_start_date == max(reverse_week_start_date)) |> 
      select(-reverse_week_start_date, -date) |> 
      map_loss_types_for_display() |> 
      janitor::clean_names(case = "title") |> 
      add_styling_to_weekly_losses() |> 
      create_downloadable_table()
  )
  
  output$overview_date <- renderInfoBox({
    infoBox(
      "Updated On:", OVERVIEW_DATE, icon = icon("calendar-days"), color = "light-blue"
    )
  })
  
  # All Loss Summary Plot
  selected_loss_types <- reactive({
    purrr::map_chr(input$loss_type_input, look_up_loss_type_for_back_end)
  })
  
  free_y_axis <- reactive({
    input$free_y_axis_selection
  })
  
  output$all_loss_types_moving_average_plot <- shiny::renderPlot({
    MOD_LOSSES_DF |> 
      enrich_daily_losses() |> 
      reshape_moving_averages() |> 
      filter(loss_type %in% selected_loss_types()) |> 
      map_loss_types_for_display() |> 
      plot_all_loss_moving_average(window_len = 7, y_axis_scale = free_y_axis())
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
    ) |> 
      select(
        c("date", "day", "personnel","personnel_diff")
      )
  })
  
  output$personnel_plot <- plotly::renderPlotly({
    rendered_personnel_df() |> 
      enrich_daily_losses() |> 
      daily_moving_average_personnel_plot()
  })
  
  output$DateRange <- renderText({
    # make sure end date later than start date
    validate(
      need(input$dates[2] > input$dates[1], "end date is earlier than start date"
      )
    )
  })
  
  
  #############
  # Equipment #
  #############
  rendered_equipment_df <- reactive({
    current_loss_type <- look_up_loss_type_for_back_end(
      input$equipment_loss_type
    )
    
    MOD_LOSSES_DF |> 
      filter(
        between(
          date,
          input$equipment_date_range[1],
          input$equipment_date_range[2]
        )
      ) |> 
      select(
        c("date", "day", current_loss_type, paste0(current_loss_type, "_diff"))
      )
  })
  
  current_loss_type <- reactive({
    current_loss_type <- LOSS_TYPE_MAP[
      LOSS_TYPE_MAP$loss_type_display == input$equipment_loss_type,
    ]$loss_type
  })
  
  output$equipment_plot <- plotly::renderPlotly({
    rendered_equipment_df() |> 
      enrich_daily_losses() |> 
      daily_moving_average_loss_plot(
        current_loss_type(), moving_average_length = 7
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