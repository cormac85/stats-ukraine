library(dplyr)
library(tidyr)

create_downloadable_table <- function(df){
  DT::datatable(
    df,
    extensions = c("Buttons"),
    options = list(
      dom = 'Bfrtip',
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
      names_to = "loss_type", values_to = "total_loss"
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
          names_to = "loss_type", values_to = "weekly_loss"
        ),
      by = c("reverse_week_start_date", "loss_type")
    ) |> 
    select(reverse_week_start_date, date, loss_type, total_loss, weekly_loss)
  
  reverse_weekly_losses_summary
}