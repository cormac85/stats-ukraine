library(dplyr)
# library(googlesheets4)
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

# oryx_sheet_url <- "https://docs.google.com/spreadsheets/d/1bngHbR0YPS7XH1oSA1VxoL4R34z60SJcR3NxguZM9GI/edit#gid=503925803"
# oryx_totals_df <- googlesheets4::read_sheet(oryx_sheet_url, sheet="Totals")

mod_personell_losses_json_url <- "https://raw.githubusercontent.com/PetroIvaniuk/2022-Ukraine-Russia-War-Dataset/main/data/russia_losses_personnel.json"
mod_personel_losses_df <- jsonlite::fromJSON(mod_personell_losses_json_url) |>
  as_tibble() |>  
  select(-`personnel*`, -POW) |>  
  mutate(date = as.Date(date))

mod_equipment_losses_json_url <- "https://raw.githubusercontent.com/PetroIvaniuk/2022-Ukraine-Russia-War-Dataset/main/data/russia_losses_equipment.json"
mod_equipment_losses_df <- jsonlite::fromJSON(mod_equipment_losses_json_url) |>
  as_tibble() |> 
  rename_with(~ tolower(gsub(" ", "_", gsub("-", "_", .x, fixed = TRUE), fixed = TRUE)))

mod_equipment_losses_df <-
  mod_equipment_losses_df |> 
  mutate(date = as.Date(date)) 

mod_equipment_losses_clean_df <-
  mod_equipment_losses_df |> 
  rowwise() |> 
  mutate(
    vehicles_and_fuel_tanks = 
      sum(
        vehicles_and_fuel_tanks, military_auto, fuel_tank, na.rm = TRUE
        )
    ) |> 
  select(
    -military_auto, -fuel_tank, -mobile_srbm_system, -greatest_losses_direction
    )

all_losses_df <- 
  mod_equipment_losses_clean_df |> 
  left_join(mod_personel_losses_df, by=join_by(date, day)) 

all_losses_df |> 
  tidyr::complete(day = seq(min(day) - 1, max(day)), 
                  fill=list(date=as.Date("2022-02-24"))) |> 
  mutate(across(-dplyr::all_of(c("day", "date")), ~tidyr::replace_na(.x, 0))) |> 
  add_lagged_cols(c("date", "day")) |> 
  readr::write_rds(file.path(here::here(), DATA_PATH, MOD_LOSSES_FILE))






