set.seed(122)

DASHBOARD_PATH = file.path("dashboards", "loss-rates")


DATA_PATH = file.path(DASHBOARD_PATH, "data")
SIDEBAR_STYLE_FILE_PATH = file.path("www", "sidebar_style.css")
HEADER_STYLE_FILE_PATH = file.path("www", "header_style.css")
LOGO_WIDTH_PX = 400


MOD_LOSSES_FILE = "mod_losses.rds"

MOD_LOSSES_DF = readr::read_rds(
  file.path(here::here(), DATA_PATH, MOD_LOSSES_FILE)
)
