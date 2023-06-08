library(dplyr)
library(tidyr)

create_downloadable_table <- function(df){
  dt <- DT::datatable(
    df,
    extensions = c("Buttons"),
    options = list(
      dom = 'Bfrtip',
      pageLength = 15,
      autoWidth = FALSE,
      scrollX=TRUE,
      buttons = list(
        # list(
        #   extend = "csv",
        #   text = "Download CSV",
        #   filename = "data",
        #   exportOptions = list(modifier = list(page = "all"))
        # ),
        list(
          extend = "excel",
          text = "Download Excel",
          filename = "data",
          exportOptions = list(modifier = list(page = "all"))
        )
      )
    ),
    rownames = FALSE
  )
    
  if (snakecase::to_title_case(CURRENT_WEEK_LOSS_COL_NAME) %in% colnames(df)){
    dt <- DT::formatStyle(
        dt,
        snakecase::to_title_case(CURRENT_WEEK_LOSS_COL_NAME),
        fontWeight = "bold",
        color = DT::styleInterval(
        cuts = c(0),
        values=c("black", "#2c9b1d")
      )
    )
  }
  
  dt
}

calculate_weekly_losses <- function(df) {
  # takes the losses data and calculates a weekly summary
  DAY_NUMBER_COL = "day"
  
  df$reverse_week_numbers <- 
    df |>
    pull(day) |> 
    (\(x) x / 7)() |>
    ceiling() |>
    as.integer() |>
    rev()
  
  df$week_numbers <- 
    df |>
    pull(day) |> 
    (\(x) x / 7)() |>
    ceiling() |>
    as.integer()
  
  df <-
    df |> 
    group_by(reverse_week_numbers) |> 
    mutate(reverse_week_start_date = min(date)) |> 
    dplyr::ungroup() |> 
    group_by(week_numbers) |> 
    mutate(week_start_date = min(date)) |> 
    dplyr::ungroup()
  
  
  reverse_weekly_losses_summary <-
    df |> 
    group_by(reverse_week_start_date) |> 
    summarise(across(-ends_with("diff"), max)) |> 
    filter(reverse_week_start_date == max(reverse_week_start_date)) |> 
    tidyr::pivot_longer(
      cols = -c("date", 
                "day",
                "reverse_week_numbers",
                "reverse_week_start_date",
                "week_start_date",
                "week_numbers"),
      names_to = "loss_type", values_to = TOTAL_LOSS_COL_NAME
    )
  
  reverse_weekly_losses_summary <-
    reverse_weekly_losses_summary |> 
    left_join(
      df |> 
        group_by(reverse_week_start_date) |> 
        summarise(across(ends_with("diff"), sum)) |> 
        filter(reverse_week_start_date == max(reverse_week_start_date)) |> 
        rename_with(\(x) gsub("_diff", "", x, fixed = TRUE)) |> 
        tidyr::pivot_longer(
          cols = -c("reverse_week_start_date"),
          names_to = "loss_type", values_to = CURRENT_WEEK_LOSS_COL_NAME
        ),
      by = c("reverse_week_start_date", "loss_type")
    ) |> 
    select(
      one_of(
        c("reverse_week_start_date", "date", "loss_type",
          TOTAL_LOSS_COL_NAME, CURRENT_WEEK_LOSS_COL_NAME)
      )
    )
  
  # Black magic that adds a "+" to the values in a the column if they're
  # greater than 0
  CURRENT_WEEK_LOSS_COL_NAME_SYM <- rlang::ensym(CURRENT_WEEK_LOSS_COL_NAME)
  
  reverse_weekly_losses_summary <-
    reverse_weekly_losses_summary |> 
    mutate(
      {{CURRENT_WEEK_LOSS_COL_NAME}} := ifelse(
        !! CURRENT_WEEK_LOSS_COL_NAME_SYM > 0,
        paste0("+", !! CURRENT_WEEK_LOSS_COL_NAME_SYM),
        !! CURRENT_WEEK_LOSS_COL_NAME_SYM
      )
    )
  
  reverse_weekly_losses_summary
}