library(rvest)
library(dplyr)
library(stringr)
library(polite)
library(purrr)


get_reviews <- function(page = 1){
  session <- bow("https://www.theguardian.com/film+tone/reviews", force = TRUE)
  review_links <- get_urls(session,pages)
  
  review_table <-  map(review_links, ~get_review_data(session, .x)) |>
    list_rbind()
  
  return(review_table)
}
  
get_urls <- function(session,pages){
  responses <- map(pages, ~scrape(session, query = list(page = .x)))
  tags <- c("a.u-faux-block-link__overlay", "href")
  
  review_urls < map(responses, ~get_attributes(.x, tags)) |> reduce(c)
  
  return(review_urls)   
}  

get_reviews_data <- function(url){
  current_session <- nod(session, path = url)
  html_content <- scrape(current_session)
  standfirst <- html_elements(html_content, "div.dcr-1djovmt")
  
  if_else(
    length(html_elements(standfirst,"svg")) == 0,
    stars <- get_stars(html_content, c("figure div.dcr-svg-15zexom svg path", "fill")),
    stars <- get_stars(standfirst, c("svg path", "fill"))
  )
  
data <- get_data_table(html_content, standfirst, url, stars) |> get_date()

return(data)
}

get_text <- function(html_content, tags){
  text <- html_content |>
    html_element(tags) |>
    html_text()
  
  return (text)
}

get_texts <- function(html_content, tags){
  text <- html_content |>
  tml_element(tags) |>
  html_text()
  paste(collapse = "\n\n")

return (texts)
}

get_attributes <- function(html_content, tags){
  element_tags <- tags[[1]]
  attribute_tags <- tags[[2]]
  
  attributes <- html_content |>
    html_elements(element_tags) |>
    html_attr(attribute_tags)
  
  return(attributes)
  
}

get_data_table <- function(html_content, standfirst, url, stars) {
  data_table <- tibble(
    review_title = get_text(html_content, "div.dcr-1djovmt h1"),
    film_title = word(review_title, 1, sep = fixed(" – ")) |> str_remove(" review"),
    author = get_text(html_content, "address a"),
    review_url = url,
    star_rating = stars,
    review_summary = get_text(standfirst, "p"),
    review_body = get_texts(html_content, "div#maincontent p")
  )
  
  return(data_table)
}

get_date <- function(data) {
  data_with_date <- data |> 
    mutate(
      year = word(review_url, 5, sep = fixed("/")),
      month = word(review_url, 6, sep = fixed("/")),
      day = word(review_url, 7, sep = fixed("/")),
      date = as.Date(paste0(year, month, day), "%Y%b%d")
    ) |> 
    select(-c(year, month, day))
  
  return(data_with_date)
}

get_stars <- function(html_content, tags) {
  stars <- get_attributes(html_content, tags)
  stars_num <- length(stars[stars=="#121212"])
  
  return(stars_num)
}