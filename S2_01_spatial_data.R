#===================================================================
#R for social and spatial Research
#Session 1: Spatial analysis with R
#Script 1: Basic GIS & analysis

#Author: Antoine Peris, TU Delft 
#Date: 02/12/2019
#===================================================================
rm(list = ls())

#we load the packages
library(sf) #to handle spatial data
library(dplyr) #for data handling
library(ggplot2) #for data visualisation
library(ggspatial) #add-on for scales & arrows in ggplot2
library(viridis)

#1. Spatial objects in R --------------

#spatial objects in R can be handled with the package
#sf. This package implements the Simple Feature standard
#of the Open Geospatial Consortium.

#To know more, there is the oline book with code examples
#https://geocompr.robinlovelace.net/spatial-class.html#sf-classes


# we can start by importing a shapefile with the function
# st_read
wijken <- st_read("C:/Users/aperis/Documents/Data/Netherlands/cbs/WijkBuurtkaart_2017_v3/wijk_2017_v3.shp")

#we can first inspect the sf object
head(wijken,1)

#sf object work like a data frame
#you can run tests to do a subset
wijken <- wijken[wijken$WATER=="NEE",]

#let's take a subset with data from Amsterdam
ams_wk <- wijken[wijken$GM_NAAM=="Amsterdam",]

#sf objects work with ggplot2, we can do maps with
#the function geom_sf

#put NA for cells with privacy issues
ams_wk[ams_wk$P_LAAGINKP<0,]$P_LAAGINKP <- NA 

#first visualisation
ggplot()+
  geom_sf(data = ams_wk,
          aes(fill=P_LAAGINKP))+
  scale_fill_gradient(low = "white", 
                      high = "steelblue")

#create a bbox
bb <- st_bbox(ams_wk)

#let's custom it a bit with a scale and white background
ggplot()+
  geom_sf(data=wijken, fill="darkgrey")+
  geom_sf(data = ams_wk,
          aes(fill=P_LAAGINKP))+
  coord_sf(xlim = c(bb[1], bb[3]),
           ylim = c(bb[2], bb[4]),
           datum = NA)+
  scale_fill_gradient(low = "white", 
                      high = "steelblue")+
  theme_bw()+
  annotation_scale()+
  annotation_north_arrow(style =  north_arrow_fancy_orienteering,
                         location= "br")


# 2. Preparation of the airbnb dataset ------

# import the airbnb data
airbnb <- read.csv("C:/Users/aperis/Documents/PhD/Education/Rworkshops/data/listings.csv.gz")

#look at the variables in the dataset
colnames(airbnb)

#select only some interesting variables
airbnb <- airbnb[,c(1,2,20,39,40,49,50,52:58,61,81,83,87,106)]

#keep only the entire houses/apartment 
#airbnb <- airbnb[airbnb$room_type=="Entire home/apt",]

#and the places that received more than one visit per
#month
airbnb <- airbnb[airbnb$reviews_per_month>0.5,]

#how does the price variable looks like?
head(airbnb$price)
str(airbnb$price)

airbnb$price <- as.character(airbnb$price)

#use the function gsub to remove the dollar sign
airbnb$price <- gsub("\\$", "", airbnb$price)
airbnb$price <- as.numeric(airbnb$price)
airbnb <- airbnb[!is.na(airbnb$price),]

head(airbnb$price)

#conversion into euros
airbnb$price <- airbnb$price*0.91

#price per accomodations
airbnb$price_acc <- airbnb$price/airbnb$accommodates

#let's look at the distribution of pirces
ggplot()+
  geom_histogram(data=airbnb, aes(x=price_acc),
                 bins = 50)

#remove the prices about 200
airbnb <- airbnb[airbnb$price_acc<150,]

#reproject the data in WGS84
ams_wk <- st_transform(ams_wk, 4326)

#we can do a first visualisation
ggplot()+
  geom_point(data = airbnb, 
          aes(x=longitude,y=latitude,color=price_acc),
          size=.3)+
  scale_color_viridis(direction = -1)+
  geom_sf(data=ams_wk, fill=NA)+
  #theme_void()+
  annotation_scale()

# Average price per neighbourhood ----------
#transform the point dataset into a sf object 
airbnb_sf <- st_as_sf(airbnb, coords = c("longitude", "latitude"))
airbnb_sf <- st_set_crs(airbnb_sf, 4326)


#perform an intersection
airbnb_wk <- st_intersection(airbnb_sf, ams_wk[,c(1,2)])

#summarise the prices
wijk_price <- airbnb_wk %>% 
  as_tibble() %>% 
  group_by(WK_CODE, WK_NAAM) %>% 
  summarise(av_pr=mean(price_acc),
            n=n())
  
#join the table with the price information and neighborhood
#information
wijken_pr <- left_join(ams_wk, wijk_price[,-2], by=c("WK_CODE"="WK_CODE"))
wijken_pr <- wijken_pr[!is.na(wijken_pr$av_pr),]

#quick visualisation
ggplot()+
  geom_sf(data=wijken_pr, aes(fill=av_pr))+
  annotation_scale()+
  annotation_north_arrow(location = "br", 
                         style = north_arrow_minimal)+
  theme_bw()



#3. Interactive visualisation ----------------
  
library(leaflet)

pal <- colorBin("Blues", domain = wijken_pr$av_pr, pretty = T)

labels <- sprintf(
  "<strong>%s</strong><br/>%g<br/>%g",
  wijken_pr$WK_NAAM, round(wijken_pr$av_pr,2), wijken_pr$n
) %>% lapply(htmltools::HTML)

leaflet(wijken_pr) %>% 
  addPolygons(fillColor = ~pal(av_pr),
              weight = 2,
              opacity = 1,
              color = "white",
              fillOpacity = 0.7,
              highlight = highlightOptions(
                weight = 5,
                color = "#666",
                fillOpacity = 0.7,
                bringToFront = TRUE),
              label = labels) %>% 
  addProviderTiles(providers$OpenStreetMap.Mapnik)

#4. Gridded statistics
#reproject the data in Amersfoort RD New
ams <- ams_wk %>% group_by(GM_NAAM) %>% summarise()
ams <- st_transform(ams, 28992)
airbnb_sf <- st_transform(airbnb_sf, 28992)

#create a grid 
grid_ams <- st_make_grid(ams, cellsize = 500)
grid_ams <- st_sf(data.frame(id=1:length(grid_ams)),geometry=grid_ams)

#keep only the cells overlapping the municipality
int <- st_intersects(grid_ams, ams)
int <- sapply(1:length(int), function(x) length(int[[x]]))
grid_ams <- grid_ams[int==1,]

#see it
ggplot()+geom_sf(data=grid_ams)

#
airbnb_gr <- st_intersection(airbnb_sf, grid_ams)
airbnb_gr$people_est <- airbnb_gr$accommodates*airbnb_gr$reviews_per_month

#compute two statistics
airbnb_gr <- airbnb_gr %>% 
  as_tibble() %>% 
  group_by(id.1) %>% 
  summarise(nb_est=sum(people_est),
            av_pr=mean(price_acc))

grid_ams <- left_join(grid_ams, airbnb_gr, by=c("id"="id.1"))


ggplot()+
  geom_sf(data=grid_ams, aes(fill=av_pr))+
  scale_fill_viridis(direction = -1)


grid_ams <- st_transform(grid_ams, 4326)

see <- grid_ams[!is.na(grid_ams$av_pr),]

pal <- colorBin("viridis",reverse = T, domain = see$av_pr, pretty = T)

leaflet(see) %>% 
  addPolygons(fillColor = ~pal(av_pr),
              weight = 2,
              opacity = 1,
              color = "white",
              fillOpacity = 0.7,
              stroke = NA) %>% 
  addProviderTiles(providers$CartoDB.Positron) %>% 
  addLegend(pal = pal, values = ~av_pr, opacity = 0.7, title = NULL,
            position = "bottomright")



#create a table with coordinates of the Oude Kerk
kerk <- data.frame(id=1, 
           name="Oude Kerk", 
           lon=4.898073 , 
           lat=52.374289)

#transform in sf object
kerk <- st_as_sf(kerk, coords = c("lon", "lat")) %>% 
  st_set_crs(4326) %>% 
  st_transform(28992)


airbnb_sf$dist <- st_distance(airbnb_sf, kerk)

mod <- lm(price~accommodates+dist+bedrooms+bathrooms, data = airbnb_sf)
summary(mod)

airbnb_sf <- airbnb_sf[!is.na(airbnb_sf$bedrooms),]
airbnb_sf <- airbnb_sf[!is.na(airbnb_sf$bathrooms),]

airbnb_sf$res <- mod$residuals

ggplot()+
  geom_sf(data=ams_wk)+
  geom_sf(data=airbnb_sf, aes(color=res), size=.3, alpha=.5)+
  scale_color_gradient2(low="red", mid = "white", high = "blue",
                        midpoint = 0)

