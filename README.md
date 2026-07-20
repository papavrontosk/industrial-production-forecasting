# Eurostat Causal Analysis with Panel Data

## Overview

This project investigates the relationship between macroeconomic indicators using panel data retrieved directly from the Eurostat API.

The analysis focuses on reproducible empirical research, including data acquisition, preprocessing, econometric modeling, and interpretation of results.

## Project Objectives

- Download official data directly from Eurostat
- Clean and prepare panel datasets
- Estimate econometric models
- Interpret empirical findings
- Produce reproducible research outputs

## Repository Structure

```
.
├── notebooks/
│   └── eurostat_analysis.ipynb
│
├── code/
│   └── analysis.R
│
├── docs/
│   ├── assignment.pdf
│   └── report.pdf
│
└── output/
    ├── figures/
    └── tables/
```

## Data

No datasets are stored in this repository.

The analysis downloads all required data directly from the Eurostat API during execution.

## Technologies

- R
- Eurostat API
- tidyverse
- fixest
- ggplot2

## Reproducibility

Install the required packages and run:

```r
source("code/analysis.R")
```

The script automatically downloads the required data and reproduces the complete analysis.

## Results

The repository contains:

- complete R implementation
- reproducible notebook
- project report
- generated figures and regression outputs

## Author

Konstantinos Papavrontos
