# 03 parcellate PET on subject surface

this demo shows how to extract parcel-level PET values from a PET volume using subject-space surface parcellation.

the workflow is:

```text
PET volume
-> project to subject surface
-> extract parcel PET values
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
f_pet
dir_freesurfer
WhichAtlas
```

`dir_subject_fs` is the absolute path to one subject's FreeSurfer output directory.

`f_pet` is the absolute path to the subject's PET volume. this file must be registered to the subject's FreeSurfer anatomical space before projection to the surface.

`dir_freesurfer` is the absolute path to the local FreeSurfer installation.

`WhichAtlas` specifies the atlas used for parcellation, for example:

```text
Schaefer100Yeo7
```

## registration and space checking

surface projection is only meaningful if the PET volume is correctly registered to the subject's FreeSurfer anatomy.

by default, the demo uses FreeSurfer `--regheader` logic. in this case, the PET volume must be voxel/header matched to the subject's FreeSurfer reference volume:

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

if the PET file is registered to FreeSurfer space but does not have the same voxel grid/header as the FreeSurfer reference volume, provide an explicit FreeSurfer registration file using:

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

the PET volume is projected to the subject's left and right cortical surfaces using:

```matlab
out_surf = hb_surfparc_project_volume_to_surface( ...
    f_pet, ...
    dir_subject_fs, ...
    'OutputDir', dir_surface, ...
    'OutputPrefix', ['pet_', atlas_name], ...
    'DirFreeSurfer', dir_freesurfer, ...
    'RegFile', f_reg, ...
    'ProjFrac', 0.5);
```

parcel PET values are then extracted using the subject-space annotation files:

```matlab
out_values = hb_surfparc_extract_parcel_values( ...
    out_surf.f_surface.lh, ...
    out_surf.f_surface.rh, ...
    f_annot_lh, ...
    f_annot_rh, ...
    'OutputFile', f_parcel_pet);
```

the extracted output is:

```text
parcel_pet
```

with dimensions:

```text
regions x frames
```

for a static PET image, this is typically:

```text
regions x 1
```

## outputs

outputs are written under:

```text
dir_subject_fs/HB/
```

surface-projected PET files are written to:

```text
dir_subject_fs/HB/surface/
```

parcel PET outputs are written to:

```text
dir_subject_fs/HB/pet/
```

the saved outputs include:

```text
pet_schaefer100yeo7_parcel_values.mat
pet_schaefer100yeo7_parcellated.mat
```

this demo documents the subject-level PET surface-parcellation step. it does not include PET data, FreeSurfer outputs, or BioFINDER-2, ADNI, or A4 data.