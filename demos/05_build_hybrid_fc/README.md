# 05 build hybrid FC

this demo builds hybrid FC matrices by combining template FC and subject-specific FC using regional model weights.

the reusable implementation is:

```text
src/hybrid/taufc_func_build_hybrid_fc.m
```

hybrid FC is a weighted connectivity matrix. for each subject, the template FC and subject FC matrices are first column-normalized. each regional FC profile is then weighted by its corresponding template-FC and subject-FC beta coefficient, and the resulting hybrid FC matrix is column-normalized again after mixing.

conceptually, the hybrid FC for each subject is:

```text
hybrid FC = weighted template FC + weighted subject FC
```

the main call is:

```matlab
HybridFC(:,:,is) = taufc_func_build_hybrid_fc( ...
    TmplFC, ...
    SubjFC(:,:,is), ...
    beta_tmpl(is,:), ...
    beta_subj(is,:));
```

the demo uses synthetic data only. the synthetic inputs have the following dimensions:

```text
TmplFC:    regions x regions
SubjFC:    regions x regions x subjects
beta_tmpl: subjects x regions
beta_subj: subjects x regions
```

`TmplFC` represents a group-level or reference connectivity matrix. `SubjFC` contains one subject-specific FC matrix per participant. `beta_tmpl` and `beta_subj` represent regional weights, such as beta coefficients estimated from regional FC–PET model fits.

to use real data, replace the synthetic `TmplFC`, `SubjFC`, `beta_tmpl`, and `beta_subj` variables in the demo script with matrices derived from the desired cohort and atlas. the number of regions must be consistent across all inputs.

the demo also computes a small `summary_table` as a smoke test. this summary is not part of the analysis. it is saved only to check that the hybrid FC matrices are related to both template FC and subject FC, and that the hybrid FC columns were normalized after mixing.

the demo saves outputs to:

```text
demos/05_build_hybrid_fc/results/
```

the saved outputs include:

```text
hybrid_fc_demo_outputs.mat
hybrid_fc_demo_subject_001.png
```

this demo documents the hybrid FC construction step. it does not include BioFINDER-2, ADNI, or A4 data, and it does not regenerate manuscript figures.

## note on interpretation

hybrid FC matrices should not be interpreted as conventional FC matrices. because the construction applies region-specific weights to seed connectivity profiles, the resulting matrices are not expected to be symmetric by design.

in this work, hybrid FC is used as a collection of regional connectivity profiles: that is, each column is treated as the hybrid seed profile for one region. the goal is not to use the full hybrid FC matrix directly for conventional graph or network analyses.

for analyses that require a symmetric matrix, users should make that choice explicitly. one simple option is to symmetrize each subject's hybrid FC matrix after construction, for example:

```matlab
HybridFC_sym = (HybridFC + HybridFC')/2;
```

additional choices, such as diagonal handling and any further normalization, should be made according to the intended downstream analysis.