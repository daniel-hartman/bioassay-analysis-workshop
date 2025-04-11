rm(list=ls())
library(tidyverse)
library(ggbeeswarm)
#setwd("~/bioassay_analysis_workshop/Meeting_3") #set your wd!
data.wide <- read_csv("three.strain.three.timepoints.csv")
head(data.wide)

#pivot the data to a longer format
data.long<-pivot_longer(data=data.wide,
                        cols = c("dead.hr.24", "dead.hr.48", "dead.hr.72"), #the colums we want to stack
                        names_to = "Time Point", #turn column names into data points
                        values_to = "dead") #move data points to 'dead' column
head(data.long)

# calculate mortality
data.long<-mutate(.data=data.long,
                  mortality = dead / total.mosquitoes) #specify new column and calc from existing ones
head(data.long)

#remove non-numeric characters from `Time Point`
data.long<-mutate(.data=data.long,
                  'Time Point' = gsub(pattern='dead.hr.', replace='', x=data.long$'Time Point'))
head(data.long)

#convert time point to numeric variable
data.long$'Time Point'<-as.numeric(data.long$'Time Point')
head(data.long)

#Summarize the mortality in control bottles by mosquito strain 
data.long %>%
  filter(treatment=="negative.control", #remove treatment bottles
         `Time Point`==72) %>% #select only the final time point
  group_by(strain) %>% #specify the groups we want to separate, if any
  summarize(mortality = ( (sum(dead)) / sum(total.mosquitoes) ) ) #summarize mortality across all control bottles

#make the plot!
data.long %>%
  filter(treatment=="treatment") %>% #filter out the negative control bottles
  ggplot(aes(x=`Time Point`, y=mortality, color=strain, group=`Time Point`)) + #define the axes we want and how we want to group the data
  geom_beeswarm(cex = 4) +
  geom_violin(fill=NA) +
  facet_grid(. ~ strain)
