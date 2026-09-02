# 07 canonical PET maps

this demo illustrates how cohort-level canonical PET maps can be estimated from parcellated tau-PET data.

canonical PET maps are reference patterns that summarize typical regional PET signal distributions across subjects, rather than representing any single participant. in this workflow, they are used to summarize off-target and on-target tau-PET binding patterns across cortical regions.

the maps are derived using region-wise Gaussian mixture modelling. for each cortical region, one- and two-component Gaussian mixture models are fitted to PET SUVR values across subjects. this approach follows Vogel et al. (2020), where Gaussian mixture modelling was used to define tau-PET positivity probabilities.

here, the same regional mixture-model framework is used to define canonical PET-pattern maps: the lower-mean component is treated as off-target binding, the higher-mean component is treated as on-target binding, and the component means across regions form the canonical off- and on-target maps.

the implementation uses the original `hb_tp2tpp.m` utility.

the demo uses synthetic PET data only, with input dimensions:

```text
regions x subjects
```

this matrix represents parcellated tau-PET data using any desired cortical atlas. to use real data, replace the synthetic `PET` matrix in the demo script with a matrix where each row is an atlas parcel and each column is a subject. the number of rows should match the selected atlas resolution.

the main call is:

```matlab
[TPP, AIC, OFTB, ONTB, GMM] = hb_tp2tpp(PET, 'WhichRegionalGMMsToReturn', regions_to_store_gmm);
```

the demo saves outputs to:

```text
demos/07_canonical_pet_maps/results/
```

the saved outputs include:

```text
canonical_pet_maps_demo_outputs.mat
canonical_pet_maps_demo.png
regional_gmm_region_010.png
```

this demo documents the canonical PET-pattern estimation step. it does not include BioFINDER-2, ADNI, or A4 data, and it does not regenerate manuscript figures.

## reference

Vogel, J. W., Iturria-Medina, Y., Strandberg, O. T., Smith, R., Levitis, E., Evans, A. C., and Hansson, O. (2020). Spread of pathological tau proteins through communicating neurons in human Alzheimer’s disease. *Nature Communications*, 11, 2612.