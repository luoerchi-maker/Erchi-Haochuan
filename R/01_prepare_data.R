# Load packages ----
library(readxl)
library(dplyr)
library(stringr)
library(here)
library(tidyr)
library(readr)
# Define file path ----
raw_path <- here("data", "raw", "ghgp_data_by_year_2023.xlsx")
print(raw_path)
print(file.exists(raw_path))

# Read Direct Point Emitters sheet ----
direct_emitters <- read_excel(
  raw_path,
  sheet = "Direct Point Emitters",
  skip = 3
)

# Filter North Carolina facilities ----
nc_initial <- direct_emitters %>%
  filter(State == "NC")

# Clean and keep core variables ----
nc_wide <- nc_initial %>%
  transmute(
    facility_id = `Facility Id`,
    frs_id = `FRS Id`,
    facility_name = `Facility Name`,
    city = City,
    state = State,
    zip_code = `Zip Code`,
    address = Address,
    county_raw = County,
    latitude = Latitude,
    longitude = Longitude,
    naics_code = `Primary NAICS Code`,
    industry_subparts = `Latest Reported Industry Type (subparts)`,
    industry_sectors = `Latest Reported Industry Type (sectors)`,
    emissions_2023 = `2023 Total reported direct emissions`,
    emissions_2022 = `2022 Total reported direct emissions`,
    emissions_2021 = `2021 Total reported direct emissions`,
    emissions_2020 = `2020 Total reported direct emissions`,
    emissions_2019 = `2019 Total reported direct emissions`
  ) %>%
  mutate(
    county_clean = county_raw %>%
      str_to_upper() %>%
      str_replace_all(" COUNTY", "") %>%
      str_trim()
  )

# Create missing-data summary ----
raw_summary <- tibble(
  metric = c(
    "NC facilities in initial subset",
    "Rows with missing county",
    "Rows with missing latitude",
    "Rows with missing longitude"
  ),
  value = c(
    nrow(nc_wide),
    sum(is.na(nc_wide$county_raw)),
    sum(is.na(nc_wide$latitude)),
    sum(is.na(nc_wide$longitude))
  )
)

# Create processed folder if needed ----
dir.create(here("data", "processed"), showWarnings = FALSE, recursive = TRUE)

# Save outputs ----
write.csv(
  nc_wide,
  here("data", "processed", "nc_direct_emitters_wide.csv"),
  row.names = FALSE
)

write.csv(
  raw_summary,
  here("data", "processed", "raw_summary.csv"),
  row.names = FALSE
)

# Print checks ----
cat("Rows in cleaned NC dataset:", nrow(nc_wide), "\n")
cat("Columns in cleaned NC dataset:", ncol(nc_wide), "\n")
cat("Missing county values:", sum(is.na(nc_wide$county_raw)), "\n")
cat("Missing latitude values:", sum(is.na(nc_wide$latitude)), "\n")
cat("Missing longitude values:", sum(is.na(nc_wide$longitude)), "\n")

# Reshape to long format ----
nc_long <- nc_wide %>%
  pivot_longer(
    cols = starts_with("emissions_"),
    names_to = "year",
    values_to = "emissions_mtco2e"
  ) %>%
  mutate(
    year = as.integer(str_remove(year, "emissions_"))
  ) %>%
  arrange(facility_id, year)

# Keep facilities with complete 2019-2023 reporting ----
nc_long_complete <- nc_long %>%
  group_by(facility_id) %>%
  filter(all(2019:2023 %in% year)) %>%
  filter(!any(is.na(emissions_mtco2e))) %>%
  ungroup()

# Create statewide totals from complete-reporting facilities ----
state_totals_complete <- nc_long_complete %>%
  group_by(year) %>%
  summarise(
    total_emissions_mtco2e = sum(emissions_mtco2e, na.rm = TRUE),
    .groups = "drop"
  )

# Save outputs ----
write.csv(
  nc_long,
  here("data", "processed", "nc_direct_emitters_long.csv"),
  row.names = FALSE
)

write.csv(
  nc_long_complete,
  here("data", "processed", "nc_direct_emitters_long_complete.csv"),
  row.names = FALSE
)

write.csv(
  state_totals_complete,
  here("data", "processed", "state_totals_complete_facilities.csv"),
  row.names = FALSE
)

# Print checks ----
cat("Rows in long dataset:", nrow(nc_long), "\n")
cat("Rows in complete-reporting long dataset:", nrow(nc_long_complete), "\n")
cat("Number of complete-reporting facilities:",
    dplyr::n_distinct(nc_long_complete$facility_id), "\n")
print(state_totals_complete)