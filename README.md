# taufc

MATLAB tools for modelling tau-PET topography using functional connectivity, accompanying the manuscript:

**Patient-specific functional brain architecture explains cortical patterns of tau PET in Alzheimer’s disease**

preprint of the original submitted manuscript:  
https://www.biorxiv.org/content/10.1101/2025.10.02.679969v2

related posts from the original submission:

- Bluesky: https://bsky.app/profile/aitchbi.bsky.social/post/3m2lr5rfwkk2q
- X/Twitter: https://x.com/aitchbi/status/1975551318103388288
- LinkedIn: https://www.linkedin.com/posts/activity-7380863207491403777-6xQs?utm_source=share&utm_medium=member_desktop&rcm=ACoAAD5v6PABrbY9LE6IqzAP2aeJJdigBOaOuFQ

## purpose

this repository provides MATLAB code implementing core analytical components of the manuscript, including rs-fMRI and PET surface processing, regional FC–PET regression, hybrid functional connectivity construction, whole-brain model comparison, canonical PET-pattern modelling, and FC null-model analyses.

subject-space surface parcellation and surface-based extraction are handled through the companion `surfparc` repository:

```text
https://github.com/aitchbi/surfparc
```

the repository is organized as a set of independent mini-demos rather than as one monolithic reproduction script. each demo illustrates one component of the analysis and documents the expected inputs and outputs.

some analyses added during manuscript revision, including Moran surrogate tau-PET analyses, cross-validated ridge-regression analyses, coefficient-stability analyses, and longitudinal follow-up analyses, require additional original scripts before they can be finalized here.

## important data note

BioFINDER-2, ADNI, and A4 imaging data are not distributed with this repository. users with access to the relevant datasets can adapt the demo input sections to their own parcellated FC and PET matrices.

## repository scope

this repository is intended to document and support reuse of the main analytical framework, rather than to provide a one-command reproduction of every manuscript figure.

the runnable examples use either synthetic data or user-supplied local neuroimaging files. controlled-access cohort data and derived participant-level imaging matrices are not included.

## quick start

in MATLAB, from the repository root:

```matlab
startup
```

then open a demo folder, read its `README.md`, and run the corresponding `taufc_demo_*.m` file.

example:

```matlab
startup
run('demos/04_regional_fc_pet_fits/taufc_demo_regional_fc_pet_fits.m')
```

## repository layout

```text
taufc/
├── README.md
├── startup.m
├── CITATION.cff
├── LICENSE
├── docs/
├── src/
│   ├── connectivity/
│   ├── regional/
│   ├── hybrid/
│   ├── wholebrain/
│   ├── canonical/
│   ├── nulls/
│   ├── ridge/
│   ├── longitudinal/
│   └── utils/
└── demos/
    ├── 01_schaefer_parcellation_surface_subject/
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

```text
https://github.com/aitchbi/matlab-utils
```

subject-space surface parcellation and surface-based extraction functions are maintained separately in:

```text
https://github.com/aitchbi/surfparc
```

graph-rewiring utilities used for strength-preserving null models are maintained separately in:

```text
https://github.com/aitchbi/graph_rewiring
```

demos or functions that depend on external utilities state this in their local README file.

## dependencies

the code is written for MATLAB. additional dependencies are listed per demo when required.

expected external dependencies include:

- MATLAB Statistics and Machine Learning Toolbox for OLS model fitting with `fitlm`
- surfparc for subject-space surface parcellation and surface-based extraction: https://github.com/aitchbi/surfparc
- Harry Behjat MATLAB utilities: https://github.com/aitchbi/matlab-utils
- graph-rewiring utilities: https://github.com/aitchbi/graph_rewiring
- FreeSurfer and local atlas resources for surface-based subject-space demos
- external Moran spectral randomization code or MATLAB implementation, where applicable

see `docs/dependencies.md` for details.

## citation

please cite the manuscript and this repository if you use the code. citation metadata for the repository is provided in `CITATION.cff` and will be updated with the final DOI after publication.

## license

this repository is distributed under the GNU General Public License v3.0. see `LICENSE` for details.