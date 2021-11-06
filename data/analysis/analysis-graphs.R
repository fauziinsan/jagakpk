## Purpose: Creating beautiful graphs azek
## Dont forget to set your directory into Jaga Github folder!

# Load relevant libraries
library(ggplot2)
library(tidyverse)
library(cowplot)
library(haven)
library(ggpubr)
#### Data preparation ####

# Load the stata dta 
district_level <- as_tibble(read_dta("data/build/output/cleaned-jaga-districtlevel-foranalysis.dta"))
subindicator_level <- as_tibble(read_dta("data/build/output/cleaned-jaga-subindicatorlevel-foranalysis.dta"))


# Long format
district_long <- district_level %>%
  gather(mean_type, mean, mean_nilai:mean_nilai_verifikasi) %>%
  gather(median_type, median, median_nilai:median_nilai_verifikasi) %>%
  gather(gap_measure, gap, gap_median:gap_mean )

subindicator_long <- subindicator_level %>%
  gather(nilai_type, nilai, nilai:nilai_verifikasi)

# Gen mean 
district_long <- district_long %>%
  group_by(mean_type) %>%
  mutate(mean_of_mean=mean(mean))

subindicator_long <- subindicator_long %>%
  group_by(nilai_type) %>%
  mutate(mean_of_nilai=mean(nilai))

### Histogram nilai analysis dan self-report ###

ggplot(district_long, aes(x=mean, color=mean_type)) +
  geom_histogram(fill="white", alpha=0.5, position="identity") +
  geom_vline(aes(xintercept=mean_of_mean, color=mean_type), linetype="dashed") +
  theme_classic() +
  xlab("Rata-rata nilai self reported dan verifikasi per kabupaten/kota") +
  scale_color_discrete(name= "Rata-rata", labels=c("Nilai self reported", "Nilai verifikasi"))

ggsave("data/analysis/Graphs/Histogram perbandingan per kabkot.png")


ggplot(subindicator_long, aes(x=nilai, color=nilai_type)) +
  geom_histogram(fill="white", alpha=0.5, position="identity") +
  geom_vline(aes(xintercept=mean_of_nilai, color=nilai_type), linetype="dashed") +
  theme_classic() +
  xlab("Rata-rata nilai self reported dan verifikasi per sub-indikator")  +
  scale_color_discrete(name= "Nilai", labels=c("Nilai self reported", "Nilai verifikasi"))

ggsave("data/analysis/Graphs/Histogram perbandingan per subindikator.png")



### Mean differences between Java and non - Java ###
#Preparation
subindicator_level <- subindicator_level %>%
  mutate(Java = ifelse(nama_prov %in% c("Prov. Jawa Barat", "Prov. Jawa Timur", "Prov. Jawa Tengah", "Prov. D.I. Yogyakarta", "Prov. Banten"), 1, 0)) %>%
  mutate(diff_nilai=nilai-nilai_verifikasi)
  
subindicator_level <-subindicator_level %>%
  group_by(Java) %>%
  mutate(mean_diff_nilai_java=mean(diff_nilai))

subindicator_level$Java <- as.factor(subindicator_level$Java) 
levels(subindicator_level$Java) <- c("Non Jawa", "Jawa")

# create point plot
subindicator_level %>% 
  group_by(Java) %>%
  summarise(
    n=n(),
    mean=mean(diff_nilai),
    sd=sd(diff_nilai)
  ) %>%
  mutate( se=sd/sqrt(n))  %>%
  mutate( ic=se * qt((1-0.05)/2 + .5, n-1)) -> test2

ggplot(test2, aes(x = Java, y = mean)) +
  geom_bar(stat = "identity", fill="white", color="black", width=0.5) +
  geom_errorbar(aes(x=Java, ymin=mean-ic, ymax=mean+ic), width=0.2) +
  labs(x="Lokasi", y="Rata-rata perbedaan nilai self reported dan verifikasi") + 
  theme_classic()
ggsave("data/analysis/Graphs/Bar chart perbedaan nilai antar  lokasi.png")


# create bar chart for the proportion
subindicator_level %>% 
  group_by(Java) %>%
  summarise(
    n=n(),
    mean=mean(gap),
    sd=sd(gap)
  ) %>%
  mutate( se=sd/sqrt(n))  %>%
  mutate( ic=se * qt((1-0.05)/2 + .5, n-1)) -> test

ggplot(test, aes(x = Java, y = mean)) +
  geom_bar(stat = "identity", fill="white", color="black", width=0.5) +
  geom_errorbar(aes(x=Java, ymin=mean-ic, ymax=mean+ic), width=0.2) +
  labs(x="Lokasi", y="Persentase sub-indikator yang menunjukan indikasi korupsi") + 
  theme_classic()

ggsave("data/analysis/Graphs/Bar graph persentase nilai antar  lokasi.png")

### Correlations ###
district_level <- district_level %>%
  mutate(diff_mean=mean_nilai-mean_nilai_verifikasi)


ggscatter(district_level, x = "poverty_rate", y = "diff_mean", 
          add = "reg.line", conf.int = TRUE, 
          cor.coef = TRUE, cor.method = "pearson",
          xlab = "Tingkat kemiskinan", ylab = "Perbedaan nilai self reported dan verifikasi")
ggsave("data/analysis/Graphs/corr poverty rate & gap per kabkot.png")

ggscatter(district_level, x = "IPM", y = "diff_mean", 
          add = "reg.line", conf.int = TRUE, 
          cor.coef = TRUE, cor.method = "pearson",
          xlab = "Tingkat kemiskinan", ylab = "Perbedaan nilai self reported dan verifikasi")
ggsave("data/analysis/Graphs/corr IPM & gap per kabkot.png")

ggscatter(district_level, x = "RLS", y = "diff_mean", 
          add = "reg.line", conf.int = TRUE, 
          cor.coef = TRUE, cor.method = "pearson",
          xlab = "Tingkat kemiskinan", ylab = "Perbedaan nilai self reported dan verifikasi")
ggsave("data/analysis/Graphs/corr RLS & gap per kabkot.png")

ggscatter(district_level, x = "indeks_keparahan_miskin", y = "diff_mean", 
          add = "reg.line", conf.int = TRUE, 
          cor.coef = TRUE, cor.method = "pearson",
          xlab = "Tingkat kemiskinan", ylab = "Perbedaan nilai self reported dan verifikasi")
ggsave("data/analysis/Graphs/corr IKM & gap per kabkot.png")









