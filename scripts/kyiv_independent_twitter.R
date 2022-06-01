library(httr)
library(dplyr)
library(png)

bearer_token <- Sys.getenv("TWITTER_BEARER")

headers <- c(`Authorization` = sprintf('Bearer %s', bearer_token))

params = list(
  query="tweets",
  `max_results` = '100',
  `tweet.fields` = 'created_at,text',
  `media.fields` = "preview_image_url",
  `exclude` = "retweets"
)

get_user_id <- function(user_name, bearer_token) {
  base_url <- "https://api.twitter.com/2/users/by/username/"
  headers <- c(`Authorization` = sprintf('Bearer %s', bearer_token))
  
  response <- httr::GET(
    url = paste0(base_url, user_name), 
    httr::add_headers(.headers=headers))
  
  httr::content(response, as = "text") %>% 
    jsonlite::fromJSON() %>% 
    return()
}

user_info <- get_user_id("Kyivindependent", bearer_token = bearer_token)

user_info$data$id

get_timeline_tweets <- function(user_id, bearer_token, max_results) {
  base_url <- "https://api.twitter.com/2/users/"
  headers <- c(`Authorization` = sprintf('Bearer %s', bearer_token))
  
  params = list(
    `max_results` = max_results,
    `tweet.fields` = 'created_at,text',
    `media.fields` = "preview_image_url,url",
    `exclude` = "retweets",
    `expansions`="attachments.media_keys,author_id"
  )
  
  response <- httr::GET(
    url = paste0(base_url, user_id, "/tweets"), 
    httr::add_headers(.headers=headers),
    query=params
  )
  
  httr::content(response) %>% 
    # jsonlite::fromJSON() %>% 
    return()
}

timeline_tweets <- get_timeline_tweets(
  user_info$data$id,
  bearer_token = bearer_token,
  max_results = 100
)
timeline_tweets

media_urls <- 
  timeline_tweets$includes$media %>% 
  purrr::map_chr(function(x) x$url) %>% 
  tibble(media_urls = .)

read_

media_urls %>% 
  purrr::map()

