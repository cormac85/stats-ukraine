library(dplyr)
library(jsonlite)

add_lagged_cols <- function(df, keep_cols) {
  df |> 
    select(-dplyr::all_of(keep_cols)) |> 
    purrr::map(\(col) col - lag(col)) |> 
    dplyr::as_tibble() |> 
    rename_with(\(x) paste0(x, "_diff")) |> 
    dplyr::bind_cols(df) |> 
    select(dplyr::all_of(keep_cols), sort(tidyselect::peek_vars()))
}

GLOBAL_VARIABLES_PATH = file.path("dashboards", "loss-rates", "global.R")
source(file.path(here::here(), GLOBAL_VARIABLES_PATH))

oryx_losses_json_url <- "https://raw.githubusercontent.com/PetroIvaniuk/2022-Ukraine-Russia-War-Dataset/main/data/russia_losses_equipment_oryx.json"

oryx_losses_df <-
  jsonlite::fromJSON(oryx_losses_json_url) |>
  as_tibble() |> 
  left_join(ORYX_LOSS_TYPE_MAP,
            by = join_by(equipment_oryx == oryx_loss_type))
  
oryx_losses_df |> 
  readr::write_rds(file.path(here::here(), DATA_PATH, ORYX_LOSSES_FILE))



