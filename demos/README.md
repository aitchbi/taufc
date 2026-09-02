# demos

the repository is organized as small independent demos. demos 01–03 require user-supplied local neuroimaging/preprocessing inputs. demos 04–10 use synthetic inputs or user-provided parcellated matrices to illustrate the core modelling workflow.

## demo index

01. Schaefer parcellation on subject surfaces
02. project rs-fMRI to subject surfaces and build FC
03. project PET to subject surfaces and parcellate
04. regional FC–PET fits
05. build hybrid FC
06. whole-brain OLS model comparison
07. canonical PET maps
08. canonical vs hybrid model comparison
09. degree-preserving FC null
10. strength-preserving FC null
11. Moran tau-PET surrogates
12. ridge-CV held-out parcels
13. split-half beta stability
14. longitudinal follow-up tau

## current status

demos 04–10 document the currently available modelling components.

demos 01–03 are surface-processing wrappers and require local FreeSurfer, rs-fMRI, PET, and atlas inputs.

demos 11–14 depend on additional scripts from revision analyses and should be finalized only once the exact analysis implementations have been added.