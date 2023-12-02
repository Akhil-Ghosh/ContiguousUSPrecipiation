library(tidyverse)
library(ggplot2)
library(reshape2)
library(sf)
library(raster)
library(rnaturalearth)
library(rnaturalearthdata)
library(animation)
library(RCurl)

cpcNumLat   <- 120 # number of lats
cpcNumLon   <- 300 # number of lons
cpcNumBytes <- cpcNumLat * cpcNumLon * 2 # 2 fields, precipitation and num gages
cpcRes      <- 0.25 # data resolution
cpcLatVec   <- 20.125 + (1:cpcNumLat)*cpcRes - cpcRes # latitudes
cpcLonVec   <- -129.875 + (1:cpcNumLon)*cpcRes - cpcRes # longitudes

plot_day <- function(year, month, day) {
  # Get data for the given year, month, and day
  day_data <- precipitation_data[[as.character(year)]][[month]][[as.character(day)]]
  
  # Plotting
  r <- raster(day_data, 
              xmn=min(cpcLonVec), xmx=max(cpcLonVec), 
              ymn=min(cpcLatVec), ymx=max(cpcLatVec))
  states <- ne_states(country = "United States of America", returnclass = "sf")
  states_raster <- rasterize(states, r, field=1)
  masked_raster <- mask(r, states_raster)
  masked_df <- rasterToPoints(masked_raster) %>% as.data.frame()
  
  p <- ggplot() +
    geom_raster(data = masked_df, aes(x = x, y = y, fill = layer)) +
    geom_sf(data = states, color = "black", fill = NA) +
    scale_fill_gradientn(colors = c("blue", "cyan", "yellow", "red"), 
                         name = "Rainfall (mm)",
                         oob = scales::squish) +  
    labs(title = paste("Rainfall on", month, day, year),
         x = "Longitude",
         y = "Latitude") +
    theme_minimal() +
    coord_sf(expand = FALSE, xlim = c(-125, -66), ylim = c(24, 49)) 
  return(p)
}

plot_day_interactive <- function(year, month, day) {
  # Get data for the given year, month, and day
  day_data <- precipitation_data[[as.character(year)]][[month]][[as.character(day)]]
  
  # Plotting
  r <- raster(day_data, 
              xmn=min(cpcLonVec), xmx=max(cpcLonVec), 
              ymn=min(cpcLatVec), ymx=max(cpcLatVec))
  states <- ne_states(country = "United States of America", returnclass = "sf")
  states_raster <- rasterize(states, r, field=1)
  masked_raster <- mask(r, states_raster)
  masked_df <- rasterToPoints(masked_raster) %>% as.data.frame()
  
  p <- ggplot() +
    geom_raster(data = masked_df, aes(x = x, y = y, fill = layer)) +
    geom_sf(data = states, color = "black", fill = NA) +
    scale_fill_gradientn(colors = c("blue", "cyan", "yellow", "red"), 
                         name = "Rainfall (mm)",
                         oob = scales::squish) +
    labs(title = paste("Rainfall on", month, day, year),
         x = "Longitude",
         y = "Latitude") +
    theme_minimal() +
    coord_sf(expand = FALSE, xlim = c(-125, -66), ylim = c(24, 49))  
  
  # Convert to interactive plot with plotly
  interactive_plot <- ggplotly(p)
  return(interactive_plot)
}