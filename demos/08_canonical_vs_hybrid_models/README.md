# 08 canonical vs hybrid models

this demo compares regional tau-PET model fits using canonical PET maps, hybrid FC, and their combination.

the goal is to illustrate how canonical PET-pattern predictors and hybrid FC predictors can be compared within the same whole-brain OLS model-comparison workflow.

the demo compares three models:

```text
canonical PET maps
hybrid FC
canonical PET maps + hybrid FC
```

`canonical PET maps` are cohort-level off- and on-target PET reference patterns. in this demo, they are used as regional PET-pattern predictors.

`hybrid FC` represents subject-specific weighted FC profiles derived from template FC and subject FC. the hybrid-FC model is fitted using the standalone `fitlhrh.m` utility.

the combined model adds the canonical PET-pattern predictors to the hybrid-FC design matrix, following the same modelling logic used in `run_fitlms.m`.

the demo uses synthetic data only. the synthetic inputs have the following dimensions:

```text
canonical.offtarget_mean: regions x 1
canonical.ontarget_mean:  regions x 1
HybridFC:                 regions x regions x subjects
PET:                      regions x subjects
```

`PET` represents parcellated tau-PET data, where each row is an atlas parcel and each column is a subject. the FC matrices must use the same atlas and region ordering as the PET matrix.

to use real data, replace the synthetic `canonical`, `HybridFC`, and `PET` variables in the demo script with matrices derived from the desired cohort and atlas. the number of PET rows must match the number of FC regions and the number of entries in each canonical PET map.

the main calls are:

```matlab
r2_canonical(is) = fitols_regional(tpicis, canonical.offtarget_mean, canonical.ontarget_mean);

[r2l, r2r] = fitlhrh(HybridFC(:,:,is), tpicis);

[r2l, r2r] = fitlhrh( ...
    HybridFC(:,:,is), ...
    tpicis, ...
    canonical.offtarget_mean, ...
    canonical.ontarget_mean);
```

these are in-sample explanatory OLS fits, not cross-validated prediction analyses.

the synthetic PET data in this demo are structured by construction: they contain both canonical PET-pattern signal and hybrid-FC-related signal. therefore, the combined model is expected to improve in this example. this demo illustrates the model-comparison workflow and should not be interpreted as a null simulation. under a true null, adding uninformative predictors should not systematically improve adjusted R2, although individual random realizations can still show small increases by chance.

the demo saves outputs to:

```text
demos/08_canonical_vs_hybrid_models/results/
```

the saved outputs include:

```text
canonical_vs_hybrid_models_demo_outputs.mat
canonical_vs_hybrid_models_demo_summary.csv
canonical_vs_hybrid_models_demo_summary.png
```

this demo documents the canonical PET-map versus hybrid-FC model-comparison step. it does not include BioFINDER-2, ADNI, or A4 data, and it does not regenerate manuscript figures.