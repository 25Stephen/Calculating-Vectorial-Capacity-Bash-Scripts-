# Vectorial Capacity Calculation for Malaria Transmission

This Bash script is designed to calculate the vectorial capacity (VC) for malaria transmission using monthly temperature data (Tn, Tm, Tx) with a rainfall factor. Additionally, it calculates other parameters such as the Extrinsic Incubation Period (EIP) and survival probability (surp) on a grid level.

## Prerequisites

Before running the script, make sure you have the following prerequisites:

1. Climate data files in NetCDF format:
   - Monthly temperature data (Tn, Tm, Tx)
   - Rainfall data

2. Required software:
   - [CDO (Climate Data Operators)](https://code.mpimet.mpg.de/projects/cdo/)

## Usage

1. Set the paths to your climate data files:
   - Modify the `path1` variable to point to the directory containing your data.

2. Configure the script parameters:
   - You can adjust the values of `a`, `b`, `c`, and `m` as needed for your calculations.
The script will perform the following steps for each specified temperature variable (e.g., Tm):

  - Regrid the temperature data to match the rainfall data grid.
  - Calculate the Extrinsic Incubation Period (EIP) using the formula: EIP = 111 / (mean2t - 16)
  - Calculate the survival probability (surp) using the formula: surp = -0.00082 * mean2t^2 + 0.0367 * mean2t + 0.522
  - Calculate the vectorial capacity (VC) using the formula: VC = (kRR * surp^EIP) / -ln(surp)
  - Output the results in NetCDF files.

Climate Data Operators (CDO) - Used for data processing and calculations.
