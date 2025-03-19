# Crowding Conservation

This repository contains the code to reproduce Figures 3A, 3B, 4, and 5 from the manuscript:

**Human V4 size predicts crowding distance**  
*Jan Kurzawski, Brenda Qiu, Noah Benson, Denis Pelli, Najib Majaj, Jonathan Winawer*

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
- **crowdingData/**: Contains data related to crowding measurements.
- **surfaceData/**: Contains rois and surface area measurements from freesurfer.
- **jov2021.mat**: datafile from preliminary experiments.
- **surface_area_data.csv**: CSV file with surface area and crowding measrures for all subjects.

## How to Use
1. Clone this repository:
   ```bash
   git clone git@github.com:jk619/crowdingConservation.git
   ```
2. Install dependencies (if required).
3. Run the provided scripts to generate the figures.

## Citation
If you use this code, please cite the original manuscript:

> Kurzawski, J., Qiu, B., Benson, N., Pelli, D., Majaj, N., & Winawer, J. (2025). Human V4 size predicts crowding distance.

## Contact
For questions or issues, please contact Jan Kurzawski or open an issue on this repository.


