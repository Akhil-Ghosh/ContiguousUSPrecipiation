library(tidyverse)
library(shiny)
library(plotly)
library(ggplot2)
library(reshape2)
library(sf)
library(raster)
library(rnaturalearth)
library(rnaturalearthdata)
library(animation)
library(RCurl)
library(httr)

source("plotting_extreme.R")
source("plot_day.R")
source("plotting_annual_range.R")


cpcNumLat   <- 120 # number of lats
cpcNumLon   <- 300 # number of lons
cpcNumBytes <- cpcNumLat * cpcNumLon * 2 # 2 fields, precipitation and num gages
cpcRes      <- 0.25 # data resolution
cpcLatVec   <- 20.125 + (1:cpcNumLat)*cpcRes - cpcRes # latitudes
cpcLonVec   <- -129.875 + (1:cpcNumLon)*cpcRes - cpcRes # longitudes

# code to download file from dropbox.
# Update later for more secure/perm solution
url <- "https://www.dropbox.com/scl/fi/s4mdrh19o54sbwnootpu2/1948_2022_precipitation_data.rds?rlkey=xoyvqrb432mupy6xpn4khgba1&dl=1" # Replace with your actual Dropbox file link

# Specify a local path to save the file
output_file <- "1948_2022_precipitation_data.rds"

# Check if the file already exists
if (!file.exists(output_file)) {
  download.file(url, destfile = output_file, mode = "wb")
  message("File downloaded from Dropbox.")
} else {
  message("File already exists locally. No download needed.")
}

precipitation_data<- readRDS('1948_2022_precipitation_data.rds')


#plot_annual_precipitation_range(2021, 2022, "Jan", "Feb")
per_matrix <- get_Xth_percentile(0.99)
#plot_extreme_events_US(1983, per_matrix)
