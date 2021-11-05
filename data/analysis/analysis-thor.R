## Set working directory
print(Sys.getenv("USERNAME"))     # <- this is your username
user <- Sys.getenv("USERNAME")

#Thoriq
  if (user == "HP Pavilion Gaming15") {
    setwd("D:/Documents/GitHub/jagakpk")
 
#Fauzi   
  } else if (user == "Fauzi") {
    setwd("xxxxxxxx")

#Hapsari    
  } else if (user == "Hapsari") {
    setwd("xxxxxxxx")
  }

## Load relevant libraries
library(ggplot2)
library(tidyverse)
library(haven)

# Load subindicator level dataset
sub_data <- as_tibble(read_dta("data/build/output/cleaned-jaga-subindicatorlevel-foranalysis.dta"))


##  DESCRIPTIVE ANALYSIS LETS GOW
##  1. Top 5 Provinces with the highest "gap cases" percentage
top5prov_pctgap <- 
  sub_data %>% group_by(nama_prov) %>%
  summarize(pct_gap = mean(gap),
            case_gap = sum(gap))  %>%
  arrange(desc(pct_gap))          %>%
  mutate(rank = row_number())     %>%
  filter(rank <= 5)               %>%
  select(-rank)                 

#   * export the data into csv
top5prov_pctgap %>% write.csv("data/analysis/prov_pctgap.csv", row.names = TRUE)

##  2. Persentase kasus gap tertinggi di setiap area intervensi
area_pctgap <- 
  sub_data %>% group_by(area_intervensi) %>%
  summarize(pct_gap  = mean(gap),
            case_gap = sum(gap))         %>%
  arrange(desc(pct_gap))                          #Optimalisasi pajak daerah tertinggi!
  
#   * export the data into csv
area_pctgap %>% write.csv("data/analysis/area_pctgap.csv", row.names = TRUE)


##  3. Top gap cases in indicator level for "Optimalisasi Pajak Daerah" area
pajak_pctgap <- 
  sub_data %>% filter(area_intervensi == "Optimalisasi Pajak Daerah") %>%
  group_by(indikator) %>%
  summarize(pct_gap  = mean(gap),
            case_gap = sum(gap)) %>%
  arrange(desc(pct_gap))  #Kurang menarik, how about the subindicator level?

pajak_pctgapsub <- 
  sub_data %>% filter(area_intervensi == "Optimalisasi Pajak Daerah") %>%
  group_by(sub_indikator) %>%
  summarize(pct_gap  = mean(gap),
            case_gap = sum(gap)) %>%
  arrange(desc(pct_gap))  ## This is more interesting?
                