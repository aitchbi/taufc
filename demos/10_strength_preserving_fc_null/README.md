# 10 strength-preserving FC null

this demo illustrates how strength-preserving null FC matrices can be used to test whether FC–PET associations depend on specific weighted network organization.

## theory

the purpose of this null model is to test whether the explanatory value of subject-specific FC depends on the detailed weighted connectivity pattern, or whether similar performance could be obtained from a randomized network that preserves simpler nodal properties.

a degree-preserving null rewires the network while preserving each node's degree. this keeps the number of connections per region fixed, but randomizes where those connections are placed.

a strength-preserving null goes one step further. it aims to preserve not only the degree sequence, but also the weighted strength sequence. nodal strength is the sum of edge weights connected to each node. preserving strength is important for weighted FC matrices, because some regions may have generally stronger connectivity than others.

the strength-preserving null used here follows the simulated-annealing framework described by Milisav et al. (2025). in this framework, a degree-preserved rewired graph is used as the starting point, and edge weights are then adjusted so that the randomized network approximately recovers the original nodal strength sequence.

this null model is useful because empirical FC could explain tau-PET patterns partly because of broad nodal properties, such as how strongly connected each region is overall. if empirical subject FC explains more tau-PET variance than strength-preserving null FC, this suggests that the result depends on more specific weighted network organization beyond nodal strength alone.

in this demo, the null FC is not implemented independently. instead, the demo activates the same strength-preserving null-model option inside `run_fitlms.m`. `run_fitlms.m` then calls the required graph-rewiring utilities internally.

the empirical subject FC, degree-preserving null FC, and strength-preserving null FC are entered into the same regional FC–PET regression pipeline, allowing direct comparison of corrected R2 values.

for more detail on the graph-rewiring procedure, including example plots and visual illustrations of degree- and strength-preserving rewired FC matrices, see the README of the graph-rewiring repository:

```text
https://github.com/aitchbi/graph_rewiring
```

that repository also describes the relationship between `fcn_randomize_str_hb.m`, `hb_graph_rewire.m`, earlier graph-rewiring code, and the strength-preserving simulated-annealing method of Milisav et al. (2025).

## dependencies

this demo requires graph-rewiring utilities from:

```text
https://github.com/aitchbi/graph_rewiring
```

in particular, the demo requires:

```text
fcn_randomize_str_hb.m
hb_graph_rewire.m
```

and any additional helper functions that these files call.

`fcn_randomize_str_hb.m` is the wrapper/updated implementation used in this workflow. the related `graph_rewiring` repository explains its relationship to earlier graph-rewiring code and to the simulated-annealing strength-preserving null model of Milisav et al. (2025).

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

the strength-preserving null model is activated using:

```matlab
opts.ShuffledSubjAnalysis_StrengthSequenceApproxPreserve.do = true;
opts.ShuffledSubjAnalysis_StrengthSequenceApproxPreserve.nstage = 5;
opts.ShuffledSubjAnalysis_StrengthSequenceApproxPreserve.niter = 500;
opts.ShuffledSubjAnalysis_StrengthSequenceApproxPreserve.temp = 1000;
```

the degree-preserving option is also enabled because the strength-preserving null uses a degree-preserving rewired graph as its starting point:

```matlab
opts.ShuffledSubjAnalysis_DegreeSequencePreserve.do = true;
opts.ShuffledSubjAnalysis_DegreeSequencePreserve.type = 'PreserveDegreeSequence';
```

the values of `nstage`, `niter`, and `temp` in the demo are intentionally small so that the example runs quickly. larger values should be used for production analyses.

## outputs

the demo saves outputs to:

```text
demos/10_strength_preserving_fc_null/results/
```

the saved outputs include:

```text
strength_preserving_fc_null_demo_outputs.mat
strength_preserving_fc_null_demo_summary.csv
strength_preserving_fc_null_demo_summary.png
```

this demo documents the strength-preserving FC null-model step. it does not include BioFINDER-2, ADNI, or A4 data, and it does not regenerate manuscript figures.

## references

Maslov, S., and Sneppen, K. (2002). Specificity and stability in topology of protein networks. *Science*, 296, 910–913.

Milisav, F., Bazinet, V., Betzel, R. F., and Misic, B. (2025). A simulated annealing algorithm for randomizing weighted networks. *Nature Computational Science*, 5, 48–64.