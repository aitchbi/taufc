# 06 whole-brain OLS model comparison

this demo compares whole-brain OLS models that explain regional tau-PET patterns using different FC predictors.

the demo uses the standalone `fitlhrh.m` utility. `fitlhrh.m` fits separate left- and right-hemisphere OLS models and returns corrected R2 values for each hemisphere. the final model score in this demo is the mean of the left- and right-hemisphere corrected R2 values.

the demo compares three FC models:

```text
template FC
subject FC
hybrid FC
```

`template FC` represents a group-level or reference connectivity matrix. `subject FC` represents each participant's own functional connectivity matrix. `hybrid FC` represents the weighted combination of template FC and subject FC profiles.

the demo uses synthetic data only. the synthetic inputs have the following dimensions:

```text
TmplFC:   regions x regions
SubjFC:   regions x regions x subjects
HybridFC: regions x regions x subjects
PET:      regions x subjects
```

`PET` represents parcellated tau-PET data, where each row is an atlas parcel and each column is a subject. the FC matrices must use the same atlas and region ordering as the PET matrix.

to use real data, replace the synthetic `TmplFC`, `SubjFC`, `HybridFC`, and `PET` variables in the demo script with matrices derived from the desired cohort and atlas. the number of PET rows must match the number of FC regions, and the number of PET columns must match the number of subject-level FC matrices.

the main calls are:

```matlab
[r2l, r2r] = fitlhrh(TmplFC, tpicis);
[r2l, r2r] = fitlhrh(SubjFC(:,:,is), tpicis);
[r2l, r2r] = fitlhrh(HybridFC(:,:,is), tpicis);
```

these are in-sample explanatory OLS fits, not cross-validated prediction analyses.

the demo saves outputs to:

```text
demos/06_wholebrain_ols_model_comparison/results/
```

the saved outputs include:

```text
wholebrain_ols_model_comparison_demo_outputs.mat
wholebrain_ols_model_comparison_demo_summary.csv
wholebrain_ols_model_comparison_demo_summary.png
```

this demo documents the whole-brain OLS model-comparison step. it does not include BioFINDER-2, ADNI, or A4 data, and it does not regenerate manuscript figures.