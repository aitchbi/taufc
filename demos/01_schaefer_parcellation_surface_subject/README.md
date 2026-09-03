# 01 Schaefer parcellation on subject surfaces

this demo shows how to warp a Schaefer atlas from fsaverage space to an individual subject's FreeSurfer surface.

the goal is to create subject-space annotation files that define the Schaefer parcels on the participant's own cortical surface. these files can then be used in later surface-based FC and PET workflows.

this demo depends on the separate `surfparc` repository:

```text
https://github.com/aitchbi/surfparc
```

the main function used here is:

```text
hb_surfparc_warp_atlas_to_subject.m
```

## required inputs

the demo requires:

```text
dir_subject_fs
dir_fsaverage_hb
dir_freesurfer
WhichAtlas
```

`dir_subject_fs` is the absolute path to one subject's FreeSurfer output directory. this directory should contain standard FreeSurfer folders such as:

```text
mri/
surf/
label/
```

`dir_fsaverage_hb` is the absolute path to the `fsaverage_hb` directory from:

```text
https://github.com/aitchbi/matlab-utils/tree/main/misc/freesurfer/fsaverage_hb
```

for example, this directory contains annotation files such as:

```text
label/lh.Schaefer2018_100Parcels_7Networks_order.annot
label/rh.Schaefer2018_100Parcels_7Networks_order.annot
```

`dir_freesurfer` is the absolute path to the local FreeSurfer installation.

`WhichAtlas` specifies the atlas to warp. currently supported examples include:

```text
Schaefer100Yeo7
Schaefer200Yeo7
Schaefer400Yeo7
```

## output location

by default, outputs are written to:

```text
dir_subject_fs/HB/
```

the demo explicitly passes this output directory as:

```matlab
dir_output = fullfile(dir_subject_fs, 'HB');
```

the subject-space annotation files are saved under:

```text
dir_subject_fs/HB/schaefer/
```

example outputs are:

```text
lh.schaefer100yeo7.annot
rh.schaefer100yeo7.annot
lh.schaefer100yeo7.parcsize.mat
rh.schaefer100yeo7.parcsize.mat
schaefer100yeo7.parcsize.mat
```

## main call

```matlab
out_parc = hb_surfparc_warp_atlas_to_subject( ...
    dir_subject_fs, ...
    dir_fsaverage_hb, ...
    WhichAtlas, ...
    'OutputDir', dir_output, ...
    'DirFreeSurfer', dir_freesurfer);
```

## notes

this demo does not include FreeSurfer outputs or atlas annotation files. users must provide these local inputs themselves.

the current demo focuses on Schaefer atlases in `fsaverage_hb`, but the underlying `surfparc` repository is intended as a more general subject-space surface-parcellation toolbox.