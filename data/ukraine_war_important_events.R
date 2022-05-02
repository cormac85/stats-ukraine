library(tibble)
library(dplyr)

important_events <- tibble::tribble(
  ~report_date, ~event_name, ~event_category, ~event_location, ~source,
  "2022-04-03", "Moskva Sinking", "naval", "Black Sea", NA_character_,
  "2022-03-25", "Start of Kyiv Withdrawal", "land", "Kyiv Oblast", NA_character_,
  "2022-03-29", "Hostomel & Bucha Liberated", "land", "Kyiv Oblast", NA_character_,
  "2022-04-18", "Battle of Donbas Declared", "land", "Donbas Oblast", "https://www.reuters.com/business/aerospace-defense/ukraine-says-battle-donbas-has-begun-russia-pushing-east-2022-04-18/",
  "2022-03-16", "Kyiv Counter Offensive Begins", "land", "Kyiv Oblast", "https://www.wsj.com/articles/ukraine-mounts-counteroffensive-to-drive-russians-back-from-kyiv-key-cities-11647428858",
  "2022-02-24", "Invasion Begins", "land", "Ukraine", NA_character_,
) %>% 
  mutate(report_date = as.Date(report_date))
