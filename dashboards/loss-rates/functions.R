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
        ~ rollapply(.x, 7, mean, align = "right", fill = NA, na.rm = TRUE, partial=TRUE),
        .names = "{.col}_7_day_moving_average"
      )
    ) |> 
    mutate(
      across(
        ends_with("diff"),
        ~ rollapply(.x, 30, mean, align = "right", fill = NA, na.rm = TRUE, partial=TRUE),
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


map_loss_types_for_display <- function(loss_types_df) {
  
  loss_types_df |> 
    dplyr::left_join(LOSS_TYPE_MAP, by="loss_type") |> 
    mutate(loss_type = loss_type_display) |> 
    select(-loss_type_display)
  
}

look_up_loss_type_for_display <- function(loss_type_str) {
  LOSS_TYPE_MAP[
    LOSS_TYPE_MAP$loss_type == loss_type_str,
  ]$loss_type_display
}

look_up_loss_type_for_back_end <- function(loss_type_display_str) {
  LOSS_TYPE_MAP[
    LOSS_TYPE_MAP$loss_type_display == loss_type_display_str,
  ]$loss_type
}


#########
# Plots #
#########
daily_moving_average_loss_plot <- function(
    df, loss_type_str, moving_average_length
  ) {
  
  rate_var <- paste0(loss_type_str, "_diff")
  
  moving_average_rate_var <- paste0(
    rate_var, "_", moving_average_length, "_day_moving_average"
  )
  
  loss_type_display_str <- look_up_loss_type_for_display(loss_type_str)
  
  plot_title <- paste(
    "Daily", 
    loss_type_display_str, 
    "Loss &", 
    moving_average_length, 
    "Day Moving Average"
  )
  
  rate_plot <- 
    df |> 
    tidyr::drop_na() |> 
    ggplot(aes(x=date, y=.data[[rate_var]])) +
    geom_col(width=1,
             fill = ukraine_palette$ukraine_blue, alpha = 0.15) +
    geom_line(aes(x=date, y=.data[[moving_average_rate_var]], group = 1),
              colour = ukraine_palette$ukraine_yellow_darkened,
              linewidth = 0.9) +
    ukraine_plot_theme() +
    theme(plot.title = element_text(size = 15)) +
    labs(title = plot_title, x = "Date", y = loss_type_display_str)
  
  plotly::ggplotly(rate_plot)
}


daily_moving_average_personnel_plot <- function(df) {
  daily_moving_average_loss_plot(
    df, loss_type_str = "personnel", moving_average_length = 30
  )
}


plot_all_loss_moving_average <- function(df, window_len, y_axis_scale) {
  
  if (y_axis_scale == "Free") plot_y_scale <- "free_y"
  if (y_axis_scale == "Fixed") plot_y_scale <- "fixed"
  
  viz <- df |> 
    filter(window_length == window_len, window_type == "moving_average") |> 
    ggplot(aes(date, loss_count)) +
    geom_bar(stat = "identity", 
             width = 1, 
             fill = ukraine_palette$ukraine_blue_dark,
             colour = ukraine_palette$ukraine_blue_dark,) +
    facet_wrap(c("loss_type"), scales = plot_y_scale, ncol = 1) +
    ukraine_plot_theme() +
    theme(
      legend.position = "none",
      axis.text.y = element_text(size=rel(1.2)),
      plot.title = element_text(size=rel(1.4), face = "bold"),
      plot.subtitle = element_text(
        face = "bold",
        size = rel(1.2),
        colour = ukraine_palette$ukraine_yellow_very_dark
      )
    ) +
    labs(
      title = paste0(
        window_len, 
        "-Day Moving Average of\nDaily Russian Losses"
      ),
      x = "Date",
      y = "Loss Count"
    ) +
    scale_color_manual(values=purrr::map_chr(unname(ukraine_palette), \(x) x))  
  
  viz
}
