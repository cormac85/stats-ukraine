library(dplyr)
library(tidyr)
library(ggplot2)
library(zoo)

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

enrich_daily_losses <- function(df) {
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
  
  # Add moving averages
  df <-
    df |> 
    arrange(date) |> 
    mutate(
      across(
        ends_with("diff"),
        ~ rollapply(.x, 7, mean, align = "right", fill = NA, partial=TRUE),
        .names = "{.col}_7_day_moving_average"
      )
    ) |> 
    mutate(
      across(
        ends_with("diff"),
        ~ rollapply(.x, 30, mean, align = "right", fill = NA, partial=TRUE),
        .names = "{.col}_30_day_moving_average"
      )
    )
  
  df <-
    df |> 
    group_by(reverse_week_numbers) |> 
    mutate(reverse_week_start_date = min(date)) |> 
    dplyr::ungroup() |> 
    group_by(week_numbers) |> 
    mutate(week_start_date = min(date)) |> 
    dplyr::ungroup()
  
  df
}


add_styling_to_weekly_losses <- function(losses_for_styling_df) {
  
  # Black magic that adds a "+" to the values in a the column if they're
  # greater than 0
  
  CURRENT_WEEK_LOSS_COL_NAME_SYM <- rlang::ensym(CURRENT_WEEK_LOSS_COL_NAME)
  
  losses_for_styling_df <-
    losses_for_styling_df |> 
    mutate(
      {{CURRENT_WEEK_LOSS_COL_NAME}} := ifelse(
        !! CURRENT_WEEK_LOSS_COL_NAME_SYM > 0,
        paste0("+", !! CURRENT_WEEK_LOSS_COL_NAME_SYM),
        !! CURRENT_WEEK_LOSS_COL_NAME_SYM
      )
    )
  
  losses_for_styling_df
}

calculate_weekly_losses <- function(df_enriched) {
  # takes the losses data and calculates a weekly summary
  reverse_weekly_losses_summary <-
    df_enriched |> 
    group_by(reverse_week_start_date) |> 
    summarise(across(-ends_with("diff"), max)) |> 
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
      df_enriched |> 
        group_by(reverse_week_start_date) |> 
        summarise(across(ends_with("diff"), sum)) |> 
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
  
  reverse_weekly_losses_summary |> tidyr::drop_na()
}

weekly_personnel_plot <- function(df) {
  personnel_df <- df |> filter(loss_type == "personnel")
  
  personnel_df <- 
    personnel_df |> 
    mutate(across(where(is.numeric), ~ replace_na(., 0)))
  
  rate_plot <- 
    personnel_df |> 
    ggplot(aes(date, !! rlang::ensym(CURRENT_WEEK_LOSS_COL_NAME), group=1)) +
    geom_line(colour = ukraine_palette$ukraine_blue_dark) +
    ukraine_plot_theme() +
    labs(title = "RAF Personnel Weekly Loss Rate",
         x = "Week End Date",
         y="Personnell Loss")
  
  rate_plot
}
