# Stats
set.seed(122)

# Paths
config_paths  = config::get("paths")
DASHBOARD_PATH = config_paths$dashboard_path
DATA_PATH = file.path(DASHBOARD_PATH, "data")
SIDEBAR_STYLE_FILE_PATH = file.path("www", "sidebar_style.css")
HEADER_STYLE_FILE_PATH = file.path("www", "header_style.css")
BODY_STYLE_FILE_PATH = file.path("www", "body_style.css")

# Display Names
CURRENT_WEEK_LOSS_COL_NAME = "current_week_loss"
TOTAL_LOSS_COL_NAME = "total_losses"

# Source
source(file.path(here::here(), DASHBOARD_PATH, "functions.R"))
source(file.path(here::here(), DASHBOARD_PATH, "theme.R"))

# CSS
LOGO_WIDTH_PX = 250
SUMMARY_PAGE_BOX_HEIGHT = 800


###############
# Data Import #
###############

MOD_LOSSES_FILE = "mod_losses.rds"
try({
  MOD_LOSSES_DF = readr::read_rds(
    file.path(here::here(), DATA_PATH, MOD_LOSSES_FILE)
  )}, 
  silent = TRUE
)

ORYX_LOSSES_FILE = "oryx_losses.rds"
try({
  ORYX_LOSSES_DF = readr::read_rds(
    file.path(here::here(), DATA_PATH, ORYX_LOSSES_FILE)
  )}, 
  silent = TRUE
)


#######################
# Pre-calculated Data #
#######################

OVERVIEW_LOSSES_DF = 
  MOD_LOSSES_DF |> 
  enrich_daily_losses() |> 
  calculate_weekly_losses()

OVERVIEW_DATE = OVERVIEW_LOSSES_DF |> dplyr::pull("date") |> max()


ORYX_MOD_COMPARISON_DF <-
  MOD_LOSSES_DF |> 
  filter(date == max(date)) |> 
  select(-date, -day, -contains("_diff")) |> 
  pivot_longer(col = everything(), names_to = "loss_type", values_to = "mod_count") |> 
  left_join(
    ORYX_LOSSES_DF |> 
      group_by(loss_type) |> 
      select(losses_total, loss_type) |> 
      summarise(oryx_count = sum(losses_total)),
    by = "loss_type"
  ) |> 
  drop_na()


##########
# Lookup #
##########

LOSS_TYPE_MAP <- dplyr::tribble(
  ~loss_type,               ~loss_type_display,
  "aircraft",                "Fixed Wing Aircraft",
  "apc",                     "Armoured Personnel Vehicle",
  "anti_aircraft_warfare",   "AA Warfare Systems",
  "cruise_missiles",         "Cruise Missiles",
  "drone",                   "UAV",
  "field_artillery",         "Artillery Systems",
  "helicopter",              "Helicopters",
  "mrl",                     "MLRS",
  "naval_ship",              "Warships / Boats",
  "personnel",               "Personnel",
  "special_equipment",       "Special Equipment",
  "tank",                    "Tanks",
  "vehicles_and_fuel_tanks", "Trucks & Fuel Tanks",
)

ORYX_LOSS_TYPE_MAP <- dplyr::tibble(
  oryx_loss_type = c(
    "Tanks", "Armoured Fighting Vehicles", "Infantry Fighting Vehicles",  # 1
    "Armoured Personnel Carriers", "Mine-Resistant Ambush Protected",  # 2
    "Infantry Mobility Vehicles", "Command Posts And Communications Stations",  # 3
    "Engineering Vehicles And Equipment", "Self-Propelled Anti-Tank Missile Systems",  # 4
    "Artillery Support Vehicles And Equipment", "Towed Artillery",  # 5
    "Self-Propelled Artillery", "Multiple Rocket Launchers", "Anti-Aircraft Guns",  # 6
    "Self-Propelled Anti-Aircraft Guns", "Surface-To-Air Missile Systems",  # 7
    "Radars", "Jammers And Deception Systems", "Aircraft", "Helicopters",  # 8
    "Unmanned Combat Aerial Vehicles", "Reconnaissance Unmanned Aerial Vehicles",  # 9
    "Naval Ships", "Trucks, Vehicles and Jeeps"  # 10
  ),
  loss_type = c(
    "tank", "apc", "apc",  # 1
    "apc", "apc",  # 2
    "apc", "apc",  # 3
    "special_equipment", "special_equipment", # 4
    "special_equipment", "field_artillery", # 5
    "field_artillery", "mrl", "anti_aircraft_warfare",  # 6
    "anti_aircraft_warfare", "anti_aircraft_warfare",  # 7
    "special_equipment", "special_equipment", "aircraft", "helicopter",  # 8
    "drone",  "drone", # 9
    "naval_ship", "vehicles_and_fuel_tanks" # 10
  )
)
