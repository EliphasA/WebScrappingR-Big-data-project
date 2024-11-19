# Importing libraries
library(janitor)
library(tidyverse)
library(readr)
library(stringr)
library(syuzhet)
library(cld2)

# Importing files
mercury_df <-  read.csv('output/Mercure Reviews.csv')
avani_df <- read.csv('output/Avani Reviews.csv')
hilton_df <- read.csv('output/Hilton Reviews.csv')

colnames(mercury_df)[colnames(mercury_df) == 'Mercure.Hotel'] <- 'Hotel Name'
colnames(hilton_df)[colnames(hilton_df) == 'Hilton.Hotel'] <- 'Hotel Name'
colnames(avani_df)[colnames(avani_df) == 'Mercure.Hotel'] <- 'Hotel Name'

# Combining datasets
final_df <- rbind(mercury_df,hilton_df,avani_df)

# ---------------
# Data Cleaning
# ---------------

# 1. Cleaning column names
final_df <- janitor::clean_names(final_df)

# 2. Extracting score number from score rating
final_df$rating_score <- substr(final_df$rating,start = 1,stop = 1)

# 3. Extracting month and year from Date column
final_df$month_year <- str_extract(final_df$date,"(\\w+ \\d{4})")
final_df <- final_df %>% 
  mutate(
    month = str_split(month_year," ",simplify = TRUE)[,1],
    year = str_split(month_year," ",simplify = TRUE)[,2]
  ) %>% 
  select(name,rating_score,month,year,hotel_name) %>% 
  na.omit(year) %>% view

# Removing Non-English words
# final_df <- final_df[detect_language(final_df$name) == "en",]

# Perform sentiment analysis on the 'name' column
final_df$sentiment_score <- get_sentiment(final_df$name, method = "syuzhet")

# Categorize the sentiments
final_df$comment_sentiment_category <- ifelse(
  final_df$sentiment_score > 0, "positive",
  ifelse(final_df$sentiment_score < 0, "negative", "neutral")
)

colnames(final_df)[colnames(final_df) == 'name'] <- 'comment'

final_df <- final_df %>% na.omit(name) %>% 
  mutate(rating_category = case_when(
    rating_score %in% c("1","2") ~ "negative",
    rating_score == "3" ~ "neutral",
    rating_score %in% c("4","5") ~ "positive",
    TRUE ~ rating_score  
    # Keep other values unchanged
  )) %>% 
  mutate(comment = gsub(",","",comment)) %>% 
  filter(year >= 2019 & year <= 2023) %>% 
  select(comment,hotel_name,month,year,rating_score,rating_category) %>% view

# Exporting dataset to csv
write.csv(final_df,'./output/Hotel Reviews.csv',row.names = FALSE)
