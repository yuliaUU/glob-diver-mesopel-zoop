# Global Diversity of Mesopelagic Mesozooplankton🐠

## Introduction
This repository contains the code and data used for the analysis and visualization of global diversity patterns of mesopelagic mesozooplankton. The analysis focuses on various zooplankton phyla, including Annelida, Arthropoda, Chaetognatha, Chordata, Cnidaria, Ctenophora, and Mollusca. The main goal is to understand species richness, range-size rarity, and their relationship with environmental variables such as temperature, salinity, and nutrient levels.

## Project Structure💾

#### Data📑
- **data/** - available t download: Egorova, Yulia (2024). Data used in the study. figshare. Dataset. [https://doi.org/10.6084/m9.figshare.26360203](https://doi.org/10.6084/m9.figshare.26360203)
  - `GEO.csv`: Contains geographical information.
  - `META_zoop.csv`: Metadata for zooplankton.
  - `ENSEMBLE_occ.wmean.csv`: Species occurrence data.
  - `ENSEMBLE_occ.wmean.tot.csv`: Total species occurrence data.
  - `sampling-effort.csv`: Sampling effort data.
  - `Temp.RData`: Mesopelagic temperature data.
  - `Temp_mean_sd.RData`: Mean and standard deviation of temperature data.
  - `ENV.RData`: Environmental variables data for mesopelagic zone.

#### Scripts📜
- **scripts/**
  - `fun/theme_Publication.R`: Custom theme for publication-quality plots.
  
#### Notebooks📒
- `script.Rmd`: Main RMarkdown file containing the analysis and plots.

#### Outputs🎨
- **img/**
  - Contains the generated figures and plots from the analysis.

## Installation🔧

#### Prerequisites
- R (version 4.0.0 or higher)
- RStudio (optional but recommended)

#### R Packages & Environment📦
The following R packages are required for the analysis:

- `readr`
- `dplyr`
- `glue`
- `latex2exp`
- `sp`
- `scales`
- `tidyr`
- `tidyverse`
- `data.table`
- `biscale`
- `cowplot`
- `ggpubr`
- `janitor`
- `sf`
- `patchwork`
- `here`
- `extrafont`
- `ggnewscale`
- `ggplot2`

To install all the required packages, you can use the following command in R:

```r
install.packages(c("readr", "dplyr", "glue", "latex2exp", "sp", "scales", "tidyr", "tidyverse", "data.table", "biscale", "cowplot", "ggpubr", "janitor", "sf", "patchwork", "here", "extrafont", "ggnewscale", "ggplot2"))
```

#### Restore the Environment

If you need to set up the environment on a different machine or restore it to a previous state, use the restore function:
```r
renv::restore()
```
## License

This project is covered under the MIT License.
