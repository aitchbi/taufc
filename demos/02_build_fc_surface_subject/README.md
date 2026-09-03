# 02 build FC on subject surface

this demo shows how to build a subject-level FC matrix from an rs-fMRI volume using subject-space surface parcellation.

the workflow is:

```text
rs-fMRI volume
-> project to subject surface
-> extract parcel time series
-> build parcel-by-parcel FC
```

the demo depends on the separate `surfparc` repository:

```text
https://github.com/aitchbi/surfparc
```

it also requires `hb_nii_verify_space_match_v2.m` from:

```text
https://github.com/aitchbi/matlab-utils
```

## required inputs

the demo requires:

```text
dir_subject_fs
f_rsfmri
dir_freesurfer
WhichAtlas
```

`dir_subject_fs` is the absolute path to one subject's FreeSurfer output directory.

`f_rsfmri` is the absolute path to the subject's rs-fMRI volume. this file must be registered to the subject's FreeSurfer anatomical space before projection to the surface.

`dir_freesurfer` is the absolute path to the local FreeSurfer installation.

`WhichAtlas` specifies the atlas used for parcellation, for example:

```text
Schaefer100Yeo7
```

## registration and space checking

surface projection is only meaningful if the rs-fMRI volume is correctly registered to the subject's FreeSurfer anatomy.

by default, the demo uses FreeSurfer `--regheader` logic. in this case, the rs-fMRI volume must be voxel/header matched to the subject's FreeSurfer reference volume:

```text
mri/ribbon.nii
```

the demo checks this before projection using:

```text
taufc_func_verify_freesurfer_space.m
```

which calls:

```text
hb_nii_verify_space_match_v2.m
```

if the rs-fMRI file is registered to FreeSurfer space but does not have the same voxel grid/header as the FreeSurfer reference volume, provide an explicit FreeSurfer registration file using:

```matlab
f_reg = '/absolute/path/to/register.dat';
```

if `f_reg` is provided, the strict voxel/header check is skipped and the registration file is passed to the surface-projection step.

## required output from demo 01

this demo expects that demo 01 has already created subject-space annotation files:

```text
dir_subject_fs/HB/schaefer/lh.schaefer100yeo7.annot
dir_subject_fs/HB/schaefer/rh.schaefer100yeo7.annot
```

these files define the atlas parcels on the subject's cortical surface.

## main processing steps

the rs-fMRI volume is projected to the subject's left and right cortical surfaces using:

```matlab
out_surf = hb_surfparc_project_volume_to_surface( ...
    f_rsfmri, ...
    dir_subject_fs, ...
    'OutputDir', dir_surface, ...
    'OutputPrefix', ['rsfmri_', atlas_name], ...
    'DirFreeSurfer', dir_freesurfer, ...
    'RegFile', f_reg, ...
    'ProjFrac', 0.5);
```

parcel time series are then extracted using the subject-space annotation files:

```matlab
out_values = hb_surfparc_extract_parcel_values( ...
    out_surf.f_surface.lh, ...
    out_surf.f_surface.rh, ...
    f_annot_lh, ...
    f_annot_rh, ...
    'OutputFile', f_timeseries);
```

finally, FC is built from the parcel time series using:

```matlab
[FC, out_fc] = taufc_func_build_fc_from_timeseries( ...
    parcel_ts, ...
    'ZeroDiag', true, ...
    'PositiveOnly', true, ...
    'FisherZ', true);
```

## outputs

outputs are written under:

```text
dir_subject_fs/HB/
```

surface-projected rs-fMRI files are written to:

```text
dir_subject_fs/HB/surface/
```

parcel time series and FC outputs are written to:

```text
dir_subject_fs/HB/fc/
```

the saved outputs include:

```text
rsfmri_schaefer100yeo7_parcel_timeseries.mat
rsfmri_schaefer100yeo7_fc.mat
```

`parcel_ts` has dimensions:

```text
regions x timepoints
```

`FC` has dimensions:

```text
regions x regions
```

this demo documents the subject-level FC construction step. it does not include rs-fMRI data, FreeSurfer outputs, or BioFINDER-2, ADNI, or A4 data.