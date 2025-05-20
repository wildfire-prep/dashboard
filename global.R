# Load packages
library(here)
# Data manipulation
library(tidyverse)
library(DT)
library(raster)
# Spatial data
library(sf)
library(leaflet)
# UI/Visualization
library(slickR)
library(ggplot2)
library(scales)
# Shiny framework
library(shiny)
library(shinydashboard)
library(shinycssloaders)
library(shinyWidgets)
library(fresh)

# Import data

# Read the file without CRS information
training_geometries_2019 <- read_sf(here(
    "data",
    "training_geometries_2019.geojson"
))

# CRS = California Albers (EPSG:3310)
training_geometries_2019 <- st_set_crs(training_geometries_2019, 3310)

# Check CRS
st_crs(training_geometries_2019)
