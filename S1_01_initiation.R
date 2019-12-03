#===================================================================
#R for social and spatial Research
#Session 1: Introduction to R
#Script 1: Syntax and objects

#Author: Antoine Peris, TU Delft 
#script adapted from Florent Le Néchet, LVMT, Paris-Est University
#Date: 20/11/2019
#===================================================================


#------------------------------
#1. A short introduction to R 
#------------------------------

#1.1 The interface ------------

#when you type an "#" in the begining of a row, the following text is a 
#comment, and will not be executed when the code is running

#You can type a command in the script and by using CTRL+ENTER
#or the "run" button, the result of the command will appear in 
#the console  
1+1

#R is working with in a default folder, you can change it if 
#you want to load or write files somewhere in your computer
#For windows users, beware if you copy/paste the path from the file explorer
#windows uses backslashes "\" and R only slashes "/". 
getwd()
setwd("PhD/Education/Rworkshops/")

#1.2 The syntax --------------------

#One of the basic principle of R is to work with variables,
#variables are named objects that are stored in the "environment"
#To store obects in your environment, you will have to 
#use an "allocation" 
a <- 1 #so a is a variable containing the number 1 

#you can test it
a == 1
a != 1

#You can do operations with these stored objects and create
#new ones 
b <- 3 * a

#R is case sentitive
B 

# This is a first kind of objects : numeric (or "num")
str(b)

# Another kind of objects : character (chr)
c <- "Hello, world!"
str(c)

# they cannot be treated the same way
b+c

#a common mistake for beginners 
b+1 # does not affect value of b
b
b <- b+1 #does
#the former "b" has been replaced by the one with the new value

# The R console does not display the result : 
# but you can check whether it worked
b


#1.3. Packages and functions ------------
#A function is a collection of statements structured together 
#for carrying out a specific task. 
#The "R base package" has 1230 

#one of them is substr, that extract characters in a character
#string.
#This function has 3 arguments:
# - the character string you want to process
# - A number to indicate where to start
# - A number to indicate where to stop 
substr(x = c, start = 1, stop = 5)

#it can also be written quicker 
substr(c,1,5)

#another function that concatenates characters
paste(c,c, sep = " ") 

#or put the characters in upper case
toupper(c)

# You can also create your own functions to avoid repeating 
#operations 
squared <- function (x) {
  x * x
}

squared(2)

#The R community is very dynamic. There are currently 15,278
#packages posted on the CRAN repository coming from people from many
#disciplines. You can download them the following way:
install.packages("ggplot2") # you have to install it only once

#and load them in your session in order to use them this way:
library(ggplot2)



#-------------
#2. R objects
#-------------

#2.1 Vectors
#Vectors the simplest type of data structure in R. 
#They are sequences of data elements of the same basic type. 

d <- c(5, 2, 10) #vector of numeric values
c(TRUE, FALSE, FALSE) #vector of logical values
c("d", "cc", "a", "bb") #vector of character values

d #Show the content of d
str(d)
d[1] # select only the first element of the vector
1:20 # another way to declare vectors

#it is possible to do operations with vectors
d*10 
d*d
sum(d)

#to order them
sort(d)

# when working with text data, it is common to have sentences as
#vetors made of words (the components)
e <- c("R","is","a","pretty","good","platform","for","data","analysis")
str(e)
e[c(5,8)] #Very commonly used way to select parts of vectors
e[1:6]
length(e)


# It is possible to change objects class in R
d
is.character(d)
d <- as.character(d)
is.character(d)
d



#2.2 The data frames -----------------
# Data frames are the most commonly used objects for data analysis
#in R
#They are used for storing data tables. 
#They are made of vectors of equal length. 

#let's empty the environment
rm(list=ls())

#first, here is a vector of characters with names
names <- c("Agata", "Aya","Heleen","Igor","Nuha",
           "Rodrigo" ,"Ruta")

#then the place of residence
pl_res <- c("Utrecht",  "Delft", "Amsterdam", "Rotterdam", "Delft",
            "Den Haag", "Delft")

#and the number of days working from home
w_from_home <- c(1,1,1,1,1,1,1)

#we can create a dataframe from them
staff <- data.frame(name=names,
                 res=pl_res,
                 wfh=w_from_home)

#print the data frame
staff

#look at one column 
staff$name

#look at the number of rows
nrow(staff)

#the number of column
ncol(staff)

#summarise the information
table(staff$res)

#store this result in a new table
cities <- as.data.frame(table(staff$res))
cities$Var1

#add distances
distance <- c(70,1,11,16,65)
cities <- cbind(cities, distance)#cbind binds columns together. You have to be 
#careful that the orders in the vector are the same. 

#when doing data analysis, it is frequent to merge data from
#different tables
new_df <- merge(staff, cities, by.x = "res", by.y = "Var1")


#the Freq column is not meaningful anymore
#we can remove it
new_df <- new_df[,-4]

#we can create a new column with the number of kilometres traveled 
#per week
new_df$km_per_w <- new_df$distance*((5-new_df$wfh)*2)

#and display the result
new_df
