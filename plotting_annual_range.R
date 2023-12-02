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


plot_annual_precipitation_range <- function(start_year, end_year, start_month, end_month) {
  # Initialize an empty list to store the cumulative data for each year
  month_order <- c("Jan" = 1, "Feb" = 2, "Mar" = 3, "Apr" = 4, "May" = 5, 
                 "Jun" = 6, "Jul" = 7, "Aug" = 8, "Sep" = 9, "Oct" = 10, 
                 "Nov" = 11, "Dec" = 12)
  cumulative_data_list <- list()
  
  # Loop over the range of years
  for (year in start_year:end_year) {
    # Extract the data for the current year
    yearly_data <- precipitation_data[[as.character(year)]]
    
    # Based on the given year, determine the range of months to consider
    if (year == start_year) {
      month_names <- names(yearly_data)[month_order[names(yearly_data)] >= month_order[start_month]]
    } else if (year == end_year) {
      month_names <- names(yearly_data)[month_order[names(yearly_data)] <= month_order[end_month]]
    } else {
      month_names <- names(yearly_data)
    }
    
    # Extract data for the months of interest and compute cumulative precipitation
    selected_month_data <- yearly_data[month_names]
    yearly_cumulative <- Reduce(`+`, lapply(selected_month_data, function(month_data) {
      Reduce(`+`, month_data)
    }))
    cumulative_data_list[[as.character(year)]] <- yearly_cumulative
  }
  
  # Combine the cumulative data across years
  overall_cumulative <- Reduce(`+`, cumulative_data_list)
  
  r <- raster(overall_cumulative, xmn=min(cpcLonVec), xmx=max(cpcLonVec), ymn=min(cpcLatVec), ymx=max(cpcLatVec))
  
  states <- ne_states(country = "United States of America", returnclass = "sf")
  great_lakes_states <- c("Michigan", "Wisconsin", "Illinois", "Indiana", "Ohio", "Minnesota", "Iowa", "Missouri", "New York", "Pennsylvania")
  states <- states[states$name %in% great_lakes_states, ]
  states_raster <- rasterize(states, r, field=1)
  masked_raster <- mask(r, states_raster)
  masked_df <- rasterToPoints(masked_raster) %>% as.data.frame()
  
  p <- ggplot() +
      geom_raster(data = masked_df, aes(x = x, y = y, fill = layer)) +
      geom_sf(data = states, color = "black", fill = NA) +
      scale_fill_gradientn(colors = c("red", "yellow", "cyan", "blue"), 
                           name = "Precipitation (mm)",
                           oob = scales::squish) +
      labs(title = paste("Cumulative Precipitation (mm) from", start_month, start_year, "to", end_month, end_year),
           x = "Longitude",
           y = "Latitude") +
      theme_minimal() +
      coord_sf(expand = FALSE, xlim = c(-98, -70), ylim = c(35, 50))
  return(p)
}


plot_annual_precipitation_US <- function(start_year, end_year, start_month, end_month) {
  # Initialize an empty list to store the cumulative data for each year
  month_order <- c("Jan" = 1, "Feb" = 2, "Mar" = 3, "Apr" = 4, "May" = 5, 
                   "Jun" = 6, "Jul" = 7, "Aug" = 8, "Sep" = 9, "Oct" = 10, 
                   "Nov" = 11, "Dec" = 12)
  cumulative_data_list <- list()
  
  # Loop over the range of years
  for (year in start_year:end_year) {
    # Extract the data for the current year
    yearly_data <- precipitation_data[[as.character(year)]]
    
    # Determine the range of months to consider for each year
    if (year == start_year) {
      month_names <- names(yearly_data)[month_order[names(yearly_data)] >= month_order[start_month]]
    } else if (year == end_year) {
      month_names <- names(yearly_data)[month_order[names(yearly_data)] <= month_order[end_month]]
    } else {
      month_names <- names(yearly_data)
    }
    
    # Extract data for the months of interest and compute cumulative precipitation
    selected_month_data <- yearly_data[month_names]
    yearly_cumulative <- Reduce(`+`, lapply(selected_month_data, function(month_data) {
      Reduce(`+`, month_data)
    }))
    cumulative_data_list[[as.character(year)]] <- yearly_cumulative
  }
  
  # Combine the cumulative data across years
  overall_cumulative <- Reduce(`+`, cumulative_data_list)
  
  # Create a raster object from the cumulative precipitation data
  r <- raster(overall_cumulative, xmn=min(cpcLonVec), xmx=max(cpcLonVec), ymn=min(cpcLatVec), ymx=max(cpcLatVec))
  
  # Retrieve state boundaries for the contiguous U.S.
  states <- ne_states(country = "United States of America", returnclass = "sf")
  
  # Create a rasterized version of state boundaries
  states_raster <- rasterize(states, r, field=1)
  
  # Mask the raster with state boundaries
  masked_raster <- mask(r, states_raster)
  masked_df <- rasterToPoints(masked_raster) %>% as.data.frame()
  
  # Create the plot
  p <- ggplot() +
    geom_raster(data = masked_df, aes(x = x, y = y, fill = layer)) +
    geom_sf(data = states, color = "black", fill = NA) +
    scale_fill_gradientn(colors = c("red", "yellow", "cyan", "blue"), 
                         name = "Precipitation (mm)",
                         oob = scales::squish) +
    labs(title = paste("Cumulative Precipitation (mm) from", start_month, start_year, "to", end_month, end_year),
         x = "Longitude",
         y = "Latitude") +
    theme_minimal() +
    coord_sf(expand = FALSE, xlim = c(-125, -66), ylim = c(24, 49)) # Adjusted limits for the entire contiguous U.S.
  return(p)
}


