library(jsonlite); library(geojsonio); library(geojsonR); library(geojsonsf); library(rgdal); library(ggplot2); library(sf); library(ggmap); library(tmaptools); library(dplyr); library(stringr)
#us_counties_json <- fromJSON("https://raw.githubusercontent.com/daniel-lij/keplerTest/master/counties.json")
#names(us_counties_json)
#us_counties_json_2 <- us_counties_json$features
#p <- plot(us_counties_json)

rm (list=ls())

# Get Counties GeoJSON file
us_c_geo <- readOGR(dsn = "C:/Git/covid-19-data/us_counties.geojson")
#plot(us_c_geo)

# Merge Counties File with Live NYTimes Covid Data
us_c_geo@data$FIPS <- as.integer(paste(us_c_geo@data$STATE, us_c_geo@data$COUNTY, sep=""))
us_c_geo_cov <- us_c_geo


# Get NYTimes Covid Data
us_c_hist <- read.csv("C:/Git/covid-19-data/us-counties.csv")
us_c_live <- read.csv("C:/Git/covid-19-data/live/us-counties.csv")

us_c_geo_cov@data <- merge(us_c_geo_cov@data, us_c_live, by.x="FIPS", by.y = "fips")

# Replace NA with 0
us_c_geo_cov@data$confirmed_cases[is.na(us_c_geo_cov@data$confirmed_cases)] <- 0
us_c_geo_cov@data$confirmed_deaths[is.na(us_c_geo_cov@data$confirmed_deaths)] <- 0

us_c_geo_cov@data$probable_cases[is.na(us_c_geo_cov@data$probable_cases)] <- 0
us_c_geo_cov@data$probable_deaths[is.na(us_c_geo_cov@data$probable_deaths)] <- 0

# Add confirmed and probably cases and deaths
us_c_geo_cov@data$tot_cases <- us_c_geo_cov@data$confirmed_cases + us_c_geo_cov@data$probable_cases
us_c_geo_cov@data$tot_deaths <- us_c_geo_cov@data$confirmed_deaths + us_c_geo_cov@data$probable_deaths

# Get population
urlfile <- "https://raw.githubusercontent.com/kingaa/covid-19-data/fips_pop/pop_est_2019.csv"
pop_2019 <- read.csv(url(urlfile))

# Pad FIPS to add 0 to left
us_c_geo_cov@data$FIPS <- str_pad(us_c_geo_cov@data$FIPS, 5, pad = "0")

# Merge the us_c_geo_cov with population data
us_c_geo_cov@data <- merge(us_c_geo_cov@data, pop_2019, by.x = "FIPS", by.y = "fips")

# Get cases and deaths by population
us_c_geo_cov@data$tot_cases_by_pop <- us_c_geo_cov@data$tot_cases/us_c_geo_cov@data$population
us_c_geo_cov@data$tot_deaths_by_pop <- us_c_geo_cov@data$tot_deaths/us_c_geo_cov@data$population
  
#head(us_c_geo_cov@data$tot_cases_by_pop, 50)

t1 <- us_c_geo_cov@data

# Test change - line of code

