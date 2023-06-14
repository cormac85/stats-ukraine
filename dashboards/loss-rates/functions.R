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
  current_week_loss_display_name <- snakecase::to_title_case(
    CURRENT_WEEK_LOSS_COL_NAME
  )
  CURRENT_WEEK_LOSS_COL_NAME_SYM <- rlang::ensym(current_week_loss_display_name)
  
  losses_for_styling_df <-
    losses_for_styling_df |> 
    mutate(
      {{current_week_loss_display_name}} := ifelse(
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


reshape_moving_averages <- function(losses_enriched_df) {
  losses_enriched_long_df <- 
    losses_enriched_df |> 
    select(date, day, week_numbers, contains("moving_average")) |> 
    pivot_longer(
      cols = contains("moving_average"),
      names_to="loss_type",
      values_to = "loss_count"
    ) |> 
    mutate(window_length = case_when(stringr::str_detect(loss_type, "7") ~ 7,
                                     stringr::str_detect(loss_type, "30") ~ 30)) |> 
    mutate(window_type = case_when(
      stringr::str_detect(loss_type, "moving_average") ~ "moving_average"
    )) |> 
    separate_wider_delim(loss_type, delim = "_diff_", names = c("loss_type", "window_info")) |> 
    select(-window_info)
  
  losses_enriched_long_df |> 
    select(day, date, week_numbers, loss_type, window_type, window_length, loss_count)  
}


#########
# Plots #
#########
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


plot_all_loss_moving_average <- function(df, window_len) {
  df |> 
    filter(window_length == window_len, window_type == "moving_average") |> 
    ggplot(
      aes(date, 
          loss_count, 
          colour = as.character(window_length))
    ) +
    geom_bar(stat = "identity") +
    facet_wrap(c("loss_type"), scales = "free_y", ncol = 1) +
    ukraine_plot_theme() +
    theme(legend.position = "none") +
    labs(
      title = paste0(
        window_len, 
        "-Day Moving Average of Daily Russian Losses"
      )
    ) +
    scale_color_manual(values=purrr::map_chr(unname(ukraine_palette), \(x) x))  
}
