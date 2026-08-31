# demo 03: project PET to subject surfaces and parcellate

## purpose

This demo shows the subject-space PET surface-projection and parcellation workflow. In the original manuscript code, this corresponds to the `ParcellateTauPet_SurfaceSUBJ` and `ParcellateAmyPet_SurfaceSUBJ` options in `script_one.m`.

The workflow registers PET data to the participant's FreeSurfer anatomical space, projects the PET image to the cortical surface, and averages values within subject-space Schaefer parcels. The output is a parcel-wise PET vector for tau-PET or Aβ-PET.

## manuscript connection

This demo relates to the preprocessing path that produced the parcellated tau-PET and Aβ-PET vectors used in the modelling analyses.

## inputs

This demo is not synthetic-data based. It requires real PET and FreeSurfer outputs.

The original BioFINDER workflow expects:

- subject/session identifiers
- FreeSurfer subject directory and surfaces
- subject-space Schaefer annotation files from demo 01
- tau-PET or Aβ-PET volume
- PET-associated T1 image
- registration tools needed to bring PET data into the participant's anatomical/FreeSurfer space
- local path adapters for cohort-specific file naming

For non-BioFINDER data, users should adapt the lower-level calls to their own data layout.

## outputs

Expected outputs are:

- parcellated tau-PET or Aβ-PET vector
- parcel labels
- optional surface/GIFTI files if requested in the lower-level utilities

In the original workflow, these are saved to subject-level PET `HB` output folders.

## dependencies

This workflow requires MATLAB, FreeSurfer, SPM12, FSL, and helper functions/scripts from:

https://github.com/aitchbi/matlab-utils

It also uses original helper utilities included under `src/utils/utils_tmp/`. Some cohort-specific path helpers under `src/utils/utils_tmp/etc/` are placeholders and must be adapted for non-local datasets.

## notes

This demo keeps the top-level call close to the original manuscript code. The purpose is to show the analysis entry point and required input organization without exposing controlled-access cohort paths or metadata.
