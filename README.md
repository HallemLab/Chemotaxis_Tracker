# Chemotaxis_Tracker
Hallem Lab Chemotaxis Tracking Codebase

Version repositories for Single Worm Chemotaxis Tracking Matlab code


## Function Description
Custom Matlab scripts used to analyze single worm chemotaxis tracking assays. 
Flexibly handles both odor tracking and CO2 tracking assays.

Will translate pixel-based x/y coordinates generated in Fiji into cm-based coordinates. 
Generates plots of worm tracks, and calculates several quantifications, 
including:
- average speed (cm/s)
- distance ratio
- pathlength (cm)
- final location relative to control zone (cm)
- final location relative to experimental zone (cm)
- time in control zone (s)
- time in experimental zone (s)

For all versions, the top-level .m file is "CT_WormTracks_vX.m"

## Versions
A note regarding version numbers within this repository. 
Version control (and advancing version numbers) is primarly handled within an internal (private) Hallem Lab Codebase. 
Therefore, numerical versions within this repository are not necessarily inclusive. 
