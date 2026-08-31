# taufc

MATLAB tools for modelling tau-PET topography using functional connectivity, accompanying the manuscript:

**Patient-specific functional brain architecture explains cortical patterns of tau PET in Alzheimer’s disease**

preprint of the original submitted manuscript:  
https://www.biorxiv.org/content/10.1101/2025.10.02.679969v2

Related posts from the original submission:

- Bluesky: https://bsky.app/profile/aitchbi.bsky.social/post/3m2lr5rfwkk2q
- X/Twitter: https://x.com/aitchbi/status/1975551318103388288
- LinkedIn: https://www.linkedin.com/posts/activity-7380863207491403777-6xQs?utm_source=share&utm_medium=member_desktop&rcm=ACoAAD5v6PABrbY9LE6IqzAP2aeJJdigBOaOuFQ

## purpose

this repository provides MATLAB code implementing the core analytical framework used in the manuscript, including subject-space Schaefer parcellation, subject-space surface projection/parcellation of rs-fMRI and PET data, regional FC-PET regression, hybrid functional connectivity construction, whole-brain model comparison, canonical PET-pattern modelling, FC null-model analyses, Moran surrogate tau-PET maps, cross-validated ridge regression, and split-half coefficient stability.

the repository is organized as a set of independent mini-demos rather than as one monolithic reproduction script. each demo illustrates one core component of the analysis and documents the expected inputs and outputs.

## important data note

BioFINDER-2, ADNI, and A4 imaging data are not distributed with this repository. users with access to the relevant datasets can adapt the demo input sections to their own parcellated FC and PET matrices.

## current status

this repository is released in connection with a revision of the original manuscript submitted for second round of peer review. the current version provides the directory structure, input/output templates, and documented entry points for the core analyses. method functions marked as pending will be filled with the exact implementations used in the revised manuscript. the repository does not intend to regenerate every figure in the manuscript. the aim is to provide reusable MATLAB implementations of the core methods underlying the main analyses. figure-specific reproduction scripts may be added in future updates.

## quick start

in MATLAB, from the repository root:

```matlab
startup
```

then open a demo folder, read its `README.md`, and run the corresponding `taufc_demo_*.m` file after replacing the input block with your own data or after the synthetic example input has been added. demos 01-03 are different from the synthetic-data demos because subject-space parcellation, rs-fMRI surface projection, and PET surface projection require real FreeSurfer outputs, imaging files, registration transforms, and local atlas resources.

example:

```matlab
startup
run('demos/04_regional_fc_pet_fits/taufc_demo_regional_fc_pet_fits.m')
```

## repository layout

```text
Behjat2026_tauFC_MATLAB/
├── README.md
├── startup.m
├── CITATION.cff
├── LICENSE
├── docs/
├── src/
│   ├── parcellation/
│   ├── regional/
│   ├── hybrid/
│   ├── wholebrain/
│   ├── canonical/
│   ├── nulls/
│   ├── ridge/
│   ├── longitudinal/
│   ├── io/
│   └── utils/
└── demos/
    ├── 01_subject_space_schaefer_parcellation/
    ├── 02_build_fc_surface_subject/
    ├── 03_parcellate_pet_surface_subject/
    ├── 04_regional_fc_pet_fits/
    ├── 05_build_hybrid_fc/
    ├── 06_wholebrain_ols_model_comparison/
    ├── 07_canonical_pet_maps/
    ├── 08_canonical_vs_hybrid_models/
    ├── 09_degree_preserving_fc_null/
    ├── 10_strength_preserving_fc_null/
    ├── 11_moran_tau_pet_surrogates/
    ├── 12_ridge_cv_heldout_parcels/
    ├── 13_beta_stability/
    └── 14_longitudinal_followup_tau/
```

## naming conventions

repository functions use the prefix `taufc_func_*.m`.

demo scripts use the prefix `taufc_demo_*.m`.

helper scripts use the prefix `taufc_scr_*.m`.

general-purpose helper functions with naming format `hb_*.m` are maintained separately in:

https://github.com/aitchbi/matlab-utils

they are not duplicated here. demos or functions that depend on `hb_*` utilities will state this in their local README file.

## dependencies

the code is written for MATLAB. additional dependencies will be listed per demo when required.

expected external dependencies include:

- Harry Behjat MATLAB utilities: https://github.com/aitchbi/matlab-utils
- external null-model implementations used for degree-preserving or degree- and strength-preserving FC randomization, where applicable
- external Moran spectral randomization code or MATLAB implementation, where applicable

See `docs/dependencies.md` for details.

## citation

please cite the manuscript and this repository if you use the code. citation metadata for the repository is provided in `CITATION.cff` and will be updated with the final DOI after publication.
