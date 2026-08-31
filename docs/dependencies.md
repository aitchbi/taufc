# dependencies

## MATLAB

The repository is MATLAB-only.

## hb utilities

General-purpose functions with names beginning with `hb_*.m` are maintained separately in:

https://github.com/aitchbi/matlab-utils

They are not duplicated here. If a demo requires one of these functions, clone that repository and add it to the MATLAB path.

## subject-space parcellation dependencies

Demo 01 requires FreeSurfer outputs and helper code from `matlab-utils`.

Relevant helper files include `hb_aparcfsavg2subj.m`, `hb_aparcfsavg2subj.sh`, `hb_annot2seg.sh`, and related FreeSurfer/MATLAB utilities.

## rs-fMRI surface projection dependencies

Demo 02 follows the original `BuildFC_SurfaceSUBJ` workflow. It requires FreeSurfer, SPM12, ANTs, the subject-space Schaefer annotations produced by demo 01, and `matlab-utils` helpers for volume-to-surface projection and parcellation.

## PET surface projection dependencies

Demo 03 follows the original `ParcellateTauPet_SurfaceSUBJ` and `ParcellateAmyPet_SurfaceSUBJ` workflows. It requires FreeSurfer, SPM12, FSL, the subject-space Schaefer annotations produced by demo 01, and `matlab-utils` helpers for PET registration, volume-to-surface projection, and surface parcellation.

## original helper utilities

Selected non-`hb_*` helper utilities from the original analysis code may be placed under `src/utils/utils_tmp/` while the public wrappers are being modularized. Some BioFINDER-specific environment helpers under `utils_tmp/etc/` are placeholders and should be adapted to local data organization.

## external null-model code

The degree-preserving and degree- and strength-preserving FC null models should use the exact external or wrapper functions used in the manuscript analyses. These implementations are not replaced here by simplified dummy code.

## Moran surrogate code

The Moran surrogate tau-PET analysis should use the exact Moran spectral randomization implementation used in the manuscript analyses. This repository will document the required inputs and dependency once the final implementation is added.
