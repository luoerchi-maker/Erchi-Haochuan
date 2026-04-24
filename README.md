# Erchi-Haochuan

ENV 872 course project by Erchi Luo and Haochuan Zhan.

## Project Question

This project asks two main questions:

1. Are reported direct greenhouse gas emissions concentrated in a small number of North Carolina counties?
2. Did statewide reported direct greenhouse gas emissions from large direct-emitting facilities decline from 2019 to 2023?

## Data Source

The project uses the EPA Greenhouse Gas Reporting Program downloadable workbook. The analysis focuses on the `Direct Point Emitters` sheet and restricts the data to North Carolina facilities. The raw Excel workbook is stored in `data/raw/ghgp_data_by_year_2023.xlsx`.

County-level mapping and boundary data were accessed in R using the `tigris` package.

## Analytical Approach

The project follows a reproducible R workflow.

- The raw workbook is imported and filtered to North Carolina facilities.
- Core facility fields and annual emissions columns for 2019 through 2023 are retained.
- County names are cleaned and standardized.
- The cleaned wide-format dataset is reshaped into a long-format facility-year dataset.
- A complete-reporting subset is created for facilities with non-missing emissions records in all five years.
- County cumulative emissions totals and statewide annual totals are calculated.
- The report uses descriptive tables, exploratory figures, and introductory analytical summaries to evaluate county concentration and statewide change.

## Repository Structure

```text
data/
  raw/
  processed/
R/
analysis.Rmd
README.md
