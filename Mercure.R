library(rvest)
library(tidyverse)
library(polite)

name <- NULL
review_content <- NULL
date <- NULL
rating <- NULL

# Scrapping Hilton reviews
for (page_result in seq(from=10,to=1000,by=10)){
  link = paste0("https://www.tripadvisor.com/Hotel_Review-g293821-d478189-Reviews-or", page_result , "-Mercure_Hotel_Windhoek-Windhoek_Khomas_Region.html")
  
  
  page <- link %>%  bow() %>% scrape()
  
  name <- rbind(name,page %>% html_nodes(".JbGkU") %>% html_text())
  review_content <- rbind(review_content,page %>% html_nodes(".C span") %>% html_text())
  date <- rbind(date, page %>% html_nodes(".PDZqu") %>% html_text()) 
  rating <- rbind(rating,page %>% html_nodes(".IaVba") %>% html_text()) 
}

max_ln <- max(c(length(name), length(review_content),length(date),length(rating)))

data_mecure <- data.frame(c(name,rep(NA, max_ln - length(name))),
                   c(review_content,rep(NA, max_ln - length(review_content))),
                   c(date,rep(NA, max_ln - length(date))),
                   c(rating,rep(NA, max_ln - length(rating))))

data_mecure$HotelName <- "Mercure Hotel"

colnames(data_mecure) <- c("Name","Review Content","Date","Rating","Mercure Hotel")

write.csv(data_mecure,'./output/Mercure Reviews.csv',row.names = FALSE)
