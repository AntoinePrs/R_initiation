#==============================================
#R for social and spatial Research
#Session 1: Introduction to R
#Script 3: summary statitics and visualisation

#Author: Antoine Peris, TU Delft
#Date: 25/11/2019
#==============================================

rm(list=ls())

library(dplyr)

#--------------------
#1. Prepare the data
#--------------------

#load the csv files with informations on neighborhoods
wijken <- read.csv("wijken_char.csv", sep = ",")
income <- read.csv("income.csv", sep = ",", stringsAsFactors = F)

#change column names
#change the column names
colnames(wijken) <- c("wk_code", "g_name", "wk_name", "pop_tot",
                      "pop_western", "pop_nonwester", "housing_tot",
                      "surface_tot", "surface_land", "surface_water")

#clean income dataset
head(income[,c(3:5)])
to_clean <- income[2,3]
income[income==to_clean] <- NA

#because of the dot, the columns are considered as characters
#we need to do a loop that will transform all the colums in numeric
for(i in 3:11){
  income[,i] <- as.numeric(income[,i])
}

#merge the two datasets
data <- left_join(wijken, income, by=c("wk_code"="WijkenEnBuurten"))

#keep only the neighborhoods in the 4 big cities of the Randstad
rand <- data %>% filter(g_name %in% c("Amsterdam", "Rotterdam", "'s-Gravenhage", "Utrecht"))

#compute the summary statistics for all the variables
summary(rand)


#creation of a new variable: share of people with an immigration background 
#in each neighbourhood
rand$imm_share <- (rand$pop_western+rand$pop_nonwester)/rand$pop_tot

#let's look at the distribution
ggplot()+
  geom_histogram(data=rand, aes(x=imm_share))+
  facet_wrap(~g_name)


#let's compare it with income
ggplot()+
  geom_point(data=rand, aes(x=imm_share,
                            y=GemiddeldInkomenPerInwoner_66))+
  labs(x="Share of immigrants", y="average income")


#we can add colors to show the different cities
ggplot()+
  geom_point(data=rand, aes(x=imm_share,
                            y=GemiddeldInkomenPerInwoner_66,
                            color=g_name))+
  labs(x="Share of immigrants", y="average income")

#use proportional symbols with the total population
ggplot()+
  geom_point(data=rand, aes(x=imm_share,
                            y=GemiddeldInkomenPerInwoner_66,
                            color=g_name,
                            size=pop_tot),
             alpha=0.5)+
  labs(x="Share of immigrants", y="average income")


#we can now highlight some outliers
#I create a table with the top 10 average income 
top <- rand %>% arrange(desc(GemiddeldInkomenPerInwoner_66)) %>% slice(1:10)

library(ggrepel)

ggplot()+
  geom_point(data=rand, aes(x=imm_share,
                            y=GemiddeldInkomenPerInwoner_66,
                            color=g_name,
                            size=pop_tot),
             alpha=0.5)+
  labs(x="Share of immigrants", y="average income")+
  geom_text_repel(data=top, aes(x=imm_share,
                                y=GemiddeldInkomenPerInwoner_66,
                                label=wk_name), size=3)



#use the ggplot in an interactive visualisation
g <- ggplot()+
  geom_point(data=rand, aes(x=imm_share,
                            y=GemiddeldInkomenPerInwoner_66,
                            color=g_name,
                            size=pop_tot,
                            label=wk_name),
             alpha=0.7)+
  labs(x="Share of immigrants", y="average income")

library(plotly)

ggplotly(g)
