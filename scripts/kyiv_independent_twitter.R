library(httr)
library(dplyr)
library(png)


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


# Setup

bearer_token <- Sys.getenv("TWITTER_BEARER")

headers <- c(`Authorization` = sprintf('Bearer %s', bearer_token))


# Get user id
user_info <- get_user_id("Kyivindependent", bearer_token = bearer_token)

user_info$data$id

# get timeline

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


media_urls <-
  media_urls %>% 
  mutate(
    media_png = purrr::map(
      media_urls, function(url) httr::content(httr::GET(url))
    )
  )

extract_image_size <- function(img, dim_index){
  dim(img)[dim_index]
}

media_urls <-
  media_urls %>% 
  mutate(
    image_width = purrr::map_int(
      media_png,
      extract_image_size,
      dim_index = 1
    ),
    image_height = purrr::map_int(
      media_png,
      extract_image_size,
      dim_index = 2
    )
  )

grid::grid.raster(media_urls$media_png[[1]])

