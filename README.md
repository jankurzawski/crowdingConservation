# Crowding Conservation

This repository contains the code to reproduce Figures 3A, 3B, 4, and 5 from the manuscript:

**Human V4 size predicts crowding distance**  
*Jan W. Kurzawski, Brenda Qiu, Noah Benson, Denis Pelli, Najib Majaj, Jonathan Winawer*

## Overview
The code in this repository is designed to:
- Recreate key figures from the study.
- Analyze the relationship between human V4 size and visual crowding distance.

## Figures
- **Figure 3A & 3B**: Visualize two example subjects
- **Figure 4**: Provides test-retest  metrics across subjects.
- **Figure 5**: Examines predictive models for crowding based on V4 size.

## Data
The `data/` directory contains the following structure:
```
data/
├── crowdingData/
├── surfaceData/
├── jov2021.mat
└── surface_area_data.csv
```
Raw fMRI data is available in BIDS format on OpenNeuro: [OpenNeuro Dataset ds005639 (Version 1.0.0)](https://openneuro.org/datasets/ds005639/versions/1.0.0).

- **crowdingData/**: Contains data related to crowding measurements.
  - `CriticalSpacing_sub-wlsubj044_Ecc=10_Ses=1.mat`: Contains critical spacing data for subject `wlsubj044` at an eccentricity of 10 degrees during session 1. Critical spacing refers to the minimum spacing at which targets can be distinguished without interference from neighboring stimuli.
- **surfaceData/**: Contains V1-V4 surface area measurements.
  - `lh.R1_rois_sub-wlsubj044`: ROI (Region of Interest) data for the left hemisphere from researcher 1 (R1). There are two researchers overall.
  - `lh.surface_sub-wlsubj044_midgray`: Surface area data of the midgray surface for subject `wlsubj044`.
- **jov2021.mat**: MATLAB data file used for the preliminary analysis. It can be used with `makeFig5.m`
- **surface_area_data.csv**: CSV file with surface area data for subjects.

## Extra Functions
The `extra/` directory contains additional functions used in the analysis:
```
extra/
├── fread3.m
├── mycmap.mat
└── read_curv.m
```
- **fread3.m**: Function to read binary files in a specific format.
- **mycmap.mat**: Colormap data used for visualizing results.
- **read_curv.m**: Function to read curvature data from surface files.

## How to Use
1. This repository is a standalone MATLAB project and does not require additional files or software.
2. Clone this repository:
   ```bash
   git clone git@github.com:jk619/crowdingConservation.git
   ```
3. Run the provided scripts to generate the figures.

## Citation
If you use this code, please cite the original manuscript:

> Kurzawski, J., Qiu, B., Benson, N., Pelli, D., Majaj, N., & Winawer, J. (Year). Human V4 size predicts crowding distance.

## Contact
For questions or issues, please contact Jan Kurzawski or open an issue on this repository.

## Poster

You can view or download the poster here:
[Download VSS 2024 Poster](https://github.com/jk619/crowdingConservation/blob/main/extra/poster2024b_compressed.pdf)

![GitHub last commit](https://img.shields.io/github/last-commit/jk619/crowdingConservation)
![GitHub issues](https://img.shields.io/github/issues/jk619/crowdingConservation)
