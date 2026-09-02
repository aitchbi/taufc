# 09 degree-preserving FC null

this demo illustrates how degree-preserving null FC matrices can be used to test whether FC–PET associations depend on specific network wiring rather than nodal degree alone.

## theory

the purpose of this null model is to test whether the explanatory value of subject-specific FC depends on the specific region-to-region wiring pattern, or whether similar performance could be obtained from a rewired network that preserves simpler graph properties.

in the degree-preserving null model, the subject FC matrix is rewired while preserving each node's degree. in other words, each region keeps the same number of connections, but the specific placement of those connections across the network is randomized. this preserves a lower-order property of the network while disrupting the detailed wiring pattern.

this is important because subject FC could appear useful simply because some regions have more connections than others. the degree-preserving null model tests against this possibility. if empirical subject FC explains more tau-PET variance than degree-preserving null FC, this suggests that the result is not explained by nodal degree alone, but depends on more specific network organization.

in this demo, the null FC is not implemented independently. instead, the demo activates the same degree-preserving null-model option inside `run_fitlms.m`. `run_fitlms.m` then calls `hb_graph_shuffle_v0.m` with:

```matlab
'Type', 'PreserveDegreeSequence'
```

the empirical subject FC and the degree-preserving null FC are then entered into the same regional FC–PET regression pipeline, allowing direct comparison of corrected R2 values.

## dependencies

this demo requires the `hb_graph_shuffle_v0.m` utility and any `hb_*` dependencies it calls. these functions originate from:

```text
https://github.com/aitchbi/matlab-utils
```

for this repository, the required functions should either be included under:

```text
src/utils/utils_tmp/
```

or otherwise be available on the MATLAB path.

the demo also requires the Statistics and Machine Learning Toolbox for `fitlm`.

## synthetic input data

the demo uses synthetic data only. the synthetic inputs have the same structure expected by `run_fitlms.m`:

```text
FC{group}:  regions x regions x subjects
PET{group}: regions x subjects
N:          subjects per group
TmplFC:     regions x regions
```

`FC` is a cell array with one entry per group. each `FC{group}` entry contains subject-level FC matrices. `PET` is a cell array with matching group structure, where each column is one subject and each row is one atlas parcel.

to use real data, replace the synthetic `FC`, `PET`, `N`, and `TmplFC` variables in the demo script with parcellated FC and tau-PET data from the desired cohort and atlas. the number of PET rows must match the number of FC regions, and the number of PET columns must match the number of FC subjects within each group.

## main call

the main call is:

```matlab
[FITLMS, TmplFC_proc, rng_setting] = run_fitlms(FC, PET, N, TmplFC, opts);
```

the degree-preserving null model is activated using:

```matlab
opts.ShuffledSubjAnalysis_DegreeSequencePreserve.do = true;
opts.ShuffledSubjAnalysis_DegreeSequencePreserve.type = 'PreserveDegreeSequence';
```

## outputs

the demo saves outputs to:

```text
demos/09_degree_preserving_fc_null/results/
```

the saved outputs include:

```text
degree_preserving_fc_null_demo_outputs.mat
degree_preserving_fc_null_demo_summary.csv
degree_preserving_fc_null_demo_summary.png
```

this demo documents the degree-preserving FC null-model step. it does not include BioFINDER-2, ADNI, or A4 data, and it does not regenerate manuscript figures.

## reference

Maslov, S., and Sneppen, K. (2002). Specificity and stability in topology of protein networks. *Science*, 296, 910–913.