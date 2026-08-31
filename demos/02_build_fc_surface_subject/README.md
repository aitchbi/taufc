# demo 02: project rs-fMRI to subject surfaces and build FC

## purpose

This demo shows the subject-space rs-fMRI surface-projection and FC construction workflow. In the original manuscript code, this corresponds to the `BuildFC_SurfaceSUBJ` option in `script_one.m`.

The workflow projects each rs-fMRI time frame to the participant's FreeSurfer cortical surface, parcellates the surface time series using subject-space Schaefer annotations, extracts parcel time series, and computes a parcel-by-parcel FC matrix.

## manuscript connection

This demo relates to the preprocessing path that produced the subject-specific FC matrices used throughout the manuscript.

## inputs

This demo is not synthetic-data based. It requires real preprocessed rs-fMRI data and FreeSurfer outputs.

The original BioFINDER workflow expects:

- subject/session identifiers
- FreeSurfer subject directory and surfaces
- subject-space Schaefer annotation files from demo 01
- preprocessed rs-fMRI volume
- registration transforms needed to bring rs-fMRI data into the participant's anatomical/FreeSurfer space
- local path adapters for cohort-specific file naming

For non-BioFINDER data, users should adapt the lower-level calls to their own data layout.

## outputs

Expected outputs are:

- parcellated rs-fMRI time series
- subject-specific FC matrix
- parcel labels

In the original workflow, these are saved to subject-level `HB/FC` output folders.

## dependencies

This workflow requires MATLAB, FreeSurfer, SPM12, ANTs, and helper functions/scripts from:

https://github.com/aitchbi/matlab-utils

It also uses original helper utilities included under `src/utils/utils_tmp/`. Some cohort-specific path helpers under `src/utils/utils_tmp/etc/` are placeholders and must be adapted for non-local datasets.

## notes

This demo keeps the top-level call close to the original manuscript code. The purpose is to show the analysis entry point and required input organization without exposing controlled-access cohort paths or metadata.
