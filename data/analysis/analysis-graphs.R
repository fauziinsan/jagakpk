## Purpose: Creating beautiful graphs azek
## Dont forget to set your directory into Jaga Github folder!

# Load relevant libraries
library(ggplot2)
library(tidyverse)
library(cowplot)
library(haven)


# Load the stata dta 
district_level <- as_tibble(read_dta("data/build/output/cleaned-jaga-districtlevel-foranalysis.dta"))
subindicator_level <- as_tibble(read_dta("data/build/output/cleaned-jaga-subindicatorlevel-foranalysis.dta"))


#combining 
### Gen Mean ###
mean_mean_nilai <- mean(district_level$mean_nilai)
mean_mean_nilai_verifikasi <- mean(district_level$mean_nilai_verifikasi)

ggplot(district_level)+
  geom_histogram(aes(mean_nilai),  fill="red", alpha=0.2) +
  geom_histogram(aes(mean_nilai_verifikasi), fill="blue", alpha=0.2) +
  geom_vline(aes(xintercept=mean_mean_nilai, color="red", size=1)) +
  geom_vline((xintercept=mean_mean_nilai_verifikasi, color="blue", size=1) +
  xlab("Nilai")

geom_vline(aes(xintercept=mean_11, color="Mean", linetype="Mean"), size=1, show_guide=TRUE)+
  geom_vline(aes(xintercept=se_11_plus, color="Std.Err", linetype="Std.Err"), show_guide=TRUE)+
  geom_vline(aes(xintercept=se_11_minus, color="Std.Err", linetype="Std.Err"), show_guide=TRUE)+