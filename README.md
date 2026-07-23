# Eurostat Industrial Production Time Series Analysis

## Overview

This project analyzes Industrial Production Index (IPI) data obtained directly from the Eurostat API. The objective is to demonstrate a complete and reproducible workflow for time series analysis, including data acquisition, preprocessing, seasonal adjustment, outlier detection, statistical modeling, and interpretation of empirical results.

## Project Objectives

- Retrieve official data directly from the Eurostat API
- Clean and preprocess time series data
- Detect and treat outliers
- Perform statistical and econometric analysis
- Produce reproducible research outputs

## Repository Structure

```
.
├── notebooks/
│   └── eurostat_industrial_production_analysis.ipynb
│
├── code/
│   └── analysis.R
│
├── docs/
│   ├── assignment.pdf
│   └── report.pdf
│
├── README.md
└── LICENSE
```

## Data

No datasets are stored in this repository.

All data are downloaded directly from the Eurostat API during execution of the analysis.

## Technologies

- R
- Eurostat API
- tidyverse
- forecast
- tsoutliers
- ggplot2

## Reproducibility

Install the required packages and run:

```r
source("code/analysis.R")
```

The script automatically downloads the required data and reproduces the complete analysis.

> **Note**
>
> This project relies on live data retrieved from the Eurostat API. Because external APIs evolve over time, dataset identifiers, query parameters, or service availability may change. If the original endpoint is modified or becomes unavailable, minor updates to the R script may be required to fully reproduce the analysis. The methodology and analytical workflow presented in this repository remain unchanged.

## Results

This repository includes:

- complete R implementation
- reproducible Jupyter notebook
- project report
- generated figures and statistical outputs

## Author

**Konstantinos Papavrontos**
