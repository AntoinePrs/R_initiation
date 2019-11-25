#===================================
#R for social and spatial Research
#Session 1: Introduction to R
#Script 2: data handling

#Author: Antoine Peris, TU Delft
#Date: 20/11/2019
#===================================


#parts are adapted form the very good tutorial
#https://uvastatlab.github.io/phdplus/dataprep.html#fnref1


#this line of code allow to remove everything from your environment
rm(list=ls())

#-------------------------------------
#1. Basic operations with data frames
#-------------------------------------

# Load and inspect a data frame -------------

#set the working directory
setwd("C:/Users/aperis/Documents/PhD/Education/Rworkshops/data/")

#load the csv file with informations on neighborhoods
wijken <- read.csv("wijken_char.csv", sep = ",")

#inspect the first lines of the data 
head(wijken)

#look at the column names 
colnames(wijken)

#look at the first line of the dataset
wijken[1,]

#look at the fourth column
wijken[,4]
#or
wijken$AantalInwoners_5

#change the column names
colnames(wijken) <- c("wk_code", "g_name", "wk_name", "pop_tot",
                      "pop_western", "pop_nonwester", "housing_tot",
                      "surface_tot", "surface_land", "surface_water")

#-----------------
#2. Data handling
#-----------------

#2.1 Querying the data frame ----------

#How many different neighbourhoods in each municipality?
table(wijken$g_name)

#store the result as a data frame
neigh_mun <- table(wijken$g_name)
neigh_mun <- as.data.frame(neigh_mun)

#order it in a decreasing way
neigh_mun <- neigh_mun[order(neigh_mun$Freq, decreasing = TRUE),]

#look at the top 10:
neigh_mun[1:10,]


# What is the population of Delfshaven in Rotterdam? 

#which line corresponds to the neighbourhood Delfshaven in Rotterdam
wijken$wk_name=="Delfshaven"
which(wijken$wk_name=="Delfshaven")

#you can directy look with the conditional test
wijken[wijken$wk_name=="Delfshaven",]$pop_tot



#2.2 Easy manipulations with dplyr -----------
#The packages dplyr (part of tidyverse) is meant for data manipulation.  
#It implements a grammar for transforming data, 
#based on functions (or verbs) that correspond to specific tasks


#first we have to load the package
library(dplyr)

#2.2.1 Isolating data

# "select" is used to extract columns by name

head(select(wijken, pop_tot))

head(select(wijken, wk_name, pop_tot))

head(select(wijken, wk_code:pop_tot))


# "filter" extacts rows that meet a logical condition.

filter(wijken, g_name=="Delft")
filter(wijken, pop_tot >= 70000)

rand <- c("Rotterdam", "Amsterdam", "Utrecht", "'s-Gravenhage")

wk_rand <- filter(wijken, g_name %in% rand)

#all logical tests:
#x < y: less than
#x > y: greater than
#x == y: equal to
#x <= y: less than or equal to
#y >= y: greater than or equal to
#x != y: not equal to
#x %in% y: is a member of
#is.na(x): is NA
#!is.na(x): is not NA


# arrange : Order rows from smallest to largest values for designated column/s.

head(arrange(wijken, pop_western))

#desc(): reverses order, largest to smallest.
head(wijken <- arrange(wijken, desc(pop_western)))

#2.2.2 Combining verbs 
#dplyr is very useful to combine operations. For that, you can use the pipe
#operator "%>%" (the shortcut is CTRL+MAJ+M)
#The pipe allows to pass the result on left into the first argument of 
#the function on the right. The output of a function becomes the input 
#for the next one. Read it in your head as "then"

wk_rand <- wijken %>% 
  filter(g_name %in% rand) %>% 
  select(wk_name, wk_code, g_name, pop_tot, housing_tot) %>% 
  arrange(desc(pop_tot))


#2.2.3 Deriving data ----------

#mutate: creates a new column
wijken <- wijken %>% 
  mutate(density = pop_tot/surface_tot)

#summarize(): computes tables of summaries
wijken %>% 
  filter(pop_tot > 0) %>% 
  summarize(smallest = min(pop_tot), 
            biggest = max(pop_tot), 
            total = n())

#group_by(): aggregates based on common column(s) values
mun <- wijken %>% 
  group_by(g_name) %>% 
  summarise(wk_nb=n(), pop=sum(pop_tot)) %>% 
  arrange(desc(pop)) 


#-----------------------
#3. First visualisation
#-----------------------

#ggplot2 is a package for data visualisation. It implements the graphics scheme 
#developped by Leland Wilkinson described in his book "The Grammar of Graphics"

#This is the basic syntax:
#ggplot(data, aes(x=, y=, color=, shape=, size=)) +
#geom_point(), or geom_histogram(), or geom_boxplot(), etc


#let's plot the distribution of municipal population
ggplot(data=mun, aes(x=pop))+
  geom_histogram()

#you can change the number og bins
ggplot(data=mun, aes(x=pop))+
  geom_histogram(bins=50)

#add a title and rename the variables
ggplot(data=mun, aes(x=pop))+
  geom_histogram(bins=50)+
  labs(x="Population", y="Frequency", title = "Distribution of Municipal populations")

#you can also modify the scale
ggplot(data=mun, aes(x=pop))+
  geom_histogram(bins=50)+
  labs(x="Population", y="Frequency", title = "Distribution of Municipal populations")+
  scale_x_log10()

#and labels
ggplot(data=mun, aes(x=pop))+
  geom_histogram(bins=50)+
  labs(x="Population", y="Frequency", title = "Distribution of Municipal populations")+
  scale_x_log10(labels = scales::comma)

#use predefined themes
ggplot(data=mun, aes(x=pop))+
  geom_histogram(bins=50)+
  labs(x="Population", y="Frequency", title = "Distribution of Municipal populations")+
  scale_x_log10(labels = scales::comma)+theme_test()




