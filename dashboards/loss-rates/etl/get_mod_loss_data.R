library(dplyr)
# library(googlesheets4)
library(jsonlite)

# oryx_sheet_url <- "https://docs.google.com/spreadsheets/d/1bngHbR0YPS7XH1oSA1VxoL4R34z60SJcR3NxguZM9GI/edit#gid=503925803"
# oryx_totals_df <- googlesheets4::read_sheet(oryx_sheet_url, sheet="Totals")

mod_personell_losses_json_url <- "https://raw.githubusercontent.com/PetroIvaniuk/2022-Ukraine-Russia-War-Dataset/main/data/russia_losses_personnel.json"
mod_personel_losses_df <- jsonlite::fromJSON(mod_personell_losses_json_url) %>%
  as_tibble() %>%
  select(-`personnel*`)

mod_equipment_losses_json_url <- "https://raw.githubusercontent.com/PetroIvaniuk/2022-Ukraine-Russia-War-Dataset/main/data/russia_losses_equipment.json"
mod_equipment_losses_df <- jsonlite::fromJSON(mod_equipment_losses_json_url) %>%
  as_tibble() %>% 
  rename_with(~ tolower(gsub(" ", "_", .x, fixed = TRUE)))

mod_equipment_losses_df <-
  mod_equipment_losses_df %>% 
  mutate(date = as.Date(date)) 

mod_equipment_losses_clean_df <-
  mod_equipment_losses_df %>% 
  rowwise() %>% 
  mutate(vehicles_and_fuel_tanks = 
           sum(
             vehicles_and_fuel_tanks, military_auto, fuel_tank, na.rm = TRUE
             )
         )

