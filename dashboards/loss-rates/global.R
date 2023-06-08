# Stats
set.seed(122)

# Paths
DASHBOARD_PATH = file.path("dashboards", "loss-rates")
DATA_PATH = file.path(DASHBOARD_PATH, "data")
SIDEBAR_STYLE_FILE_PATH = file.path("www", "sidebar_style.css")
HEADER_STYLE_FILE_PATH = file.path("www", "header_style.css")
BODY_STYLE_FILE_PATH = file.path("www", "body_style.css")

# Display Names
CURRENT_WEEK_LOSS_COL_NAME = "current_week_loss"
TOTAL_LOSS_COL_NAME = "total_losses"

# Source
source(file.path(here::here(), DASHBOARD_PATH, "functions.R"))

# CSS
LOGO_WIDTH_PX = 250

# Data Import
MOD_LOSSES_FILE = "mod_losses.rds"
try({
  MOD_LOSSES_DF = readr::read_rds(
    file.path(here::here(), DATA_PATH, MOD_LOSSES_FILE)
  )}, 
  silent = TRUE
)

# Pre-calculated Data
OVERVIEW_LOSSES_DF = calculate_weekly_losses(MOD_LOSSES_DF)
OVERVIEW_DATE = OVERVIEW_LOSSES_DF |> dplyr::pull("date") |> max()

