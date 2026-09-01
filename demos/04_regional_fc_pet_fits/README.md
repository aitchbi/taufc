# 04 regional FC PET fits

this demo runs regional FC–PET regression models using the original `run_fitlms.m` utility.

the goal is to estimate how well regional tau-PET patterns can be explained by functional connectivity profiles. for each group, the model relates parcellated tau-PET signal to FC profiles across cortical regions.

the demo compares three model families:

```text
template FC
subject FC
template FC + subject FC
```

`template FC` represents a group-level or reference connectivity matrix. `subject FC` represents each participant's own functional connectivity matrix. the combined model evaluates whether subject-specific FC explains regional PET variation beyond the template FC profile.

the demo uses synthetic data only. the synthetic inputs have the same structure expected by `run_fitlms.m`:

```text
FC{group}:  regions x regions x subjects
PET{group}: regions x subjects
N:          subjects per group
TmplFC:     regions x regions
```

`FC` is a cell array with one entry per diagnostic or biomarker group. each `FC{group}` entry contains subject-level FC matrices. `PET` is a cell array with matching group structure, where each column is one subject and each row is one atlas parcel.

to use real data, replace the synthetic `FC`, `PET`, `N`, and `TmplFC` variables in the demo script with parcellated FC and tau-PET data from the desired cohort and atlas. the number of PET rows must match the number of FC regions, and the number of PET columns must match the number of FC subjects within each group.

the main call is:

```matlab
[FITLMS, TmplFC_proc, rng_setting] = run_fitlms(FC, PET, N, TmplFC, opts);
```

the demo saves outputs to:

```text
demos/04_regional_fc_pet_fits/results/
```

the saved outputs include:

```text
regional_fc_pet_fits_demo_outputs.mat
regional_fc_pet_fits_demo_summary.csv
regional_fc_pet_fits_demo_summary.png
```

this demo documents the regional FC–PET model-fitting step. it does not include BioFINDER-2, ADNI, or A4 data, and it does not regenerate manuscript figures.