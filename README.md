# Tilt_Transitions_Aplysia
This repository contains the code that reproduces the figures of the manuscript 



> Transitions between locomotion modes are driven by changes in the tilt of a neural attractor
> 
> Andrea Colins Rodriguez*, Evan Hill, William Frost, Mark D. Humphries*
> 
>  [DOI:](https:/)

# Data

The analyses require behavioural and neural recordings that will be published upon acceptance. 

# Hardware requirements
This package requires only a standard computer. 

# Software requirements

- Matlab 2023 or 2024: To reproduce the figures of the paper.
  

## Dependencies
This code performs jPCA in MATLAB. The toolbox required for this analysis can be downloaded here:
-  jPCA: [original jPCA toolbox for Matlab (Mark Churchland)](https://churchland.zuckermaninstitute.columbia.edu/content/code)
  
  or 
  
-  jPCA : [updated jPCA toolbox for Matlab](https://github.com/AndreaColinsR/jPCA_Aplysia)

  For other analyses, the following MATLAB toolboxes are required.

- Curve Fitting Toolbox                                 
- Image Processing Toolbox                              
- Optimization Toolbox                                 
- Parallel Computing Toolbox                            
- Signal Processing Toolbox                             
- Statistics and Machine Learning Toolbox              

# Reproducing figures of the papers
1. Download the behavioural and neural data (Pending!)
2. Download the code from this repository
3. Place the dataset folder as a subfolder of the code in this repository
4. Download the jPCA toolbox and place it as a subfolder of the code in this repository
5. Open the file `Main_reproduce_figures.m` in Matlab and press Run

# Expected output


This script generates:

- 7 figures corresponding to the main figures of the text.

- 2 supplementary figures that were used to compute complementary statistics.
  
- 7 supplementary videos

  Note: By default, the code performs the analyses to reproduce all figures and videos shown in the paper. To produce only the main figures, please comment out the sections Supplementary figures and Supplementary videos at the end of `Main_reproduce_figures.m`. 

# License
This project is covered under the MIT License.

