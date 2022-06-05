library(httr)
library(dplyr)
library(png)
library(tesseract)
library(imager)


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

media_urls$media_key <-
  timeline_tweets$includes$media %>% 
  purrr::map_chr(function(x) x$media_key)

media_urls <-
  media_urls %>% 
  mutate(
    media_png = imager::map_il(
      media_urls, load.image
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


russia_loss_images <-
  media_urls %>% 
  filter(image_height == 1080, image_width == 1080)

grid::grid.raster(russia_loss_images$media_png[[1]])

tweet_data_from_media_key <- function(media_key, tweet_data){
  media_keys_mask <- 
    tweet_data %>% 
    purrr::map_lgl(function(tweet) !is.null(tweet$attachments$media_keys[[1]])) 
  
  media_tweets <- tweet_data[media_keys_mask]
  
  current_media_keys_mask <- 
    media_tweets %>% 
    purrr::map_lgl(function(tweet) tweet$attachments$media_keys[[1]] == media_key)
  
  media_tweets[current_media_keys_mask]
}

russia_loss_images <-
  russia_loss_images %>% 
  mutate(tweet_info = purrr::map(media_key, tweet_data_from_media_key, timeline_tweets$data))

eng <- tesseract("eng")
text <- tesseract::ocr(russia_loss_images$media_urls[[1]], engine = eng)
text

russia_loss_images$media_png %>%  plot()
