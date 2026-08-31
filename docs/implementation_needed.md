# implementation details still needed

The current repository skeleton intentionally avoids simplified dummy implementations of manuscript methods. The following exact implementation details are needed before each module is finalized.

## subject-space Schaefer parcellation

- confirm final public path layout for FreeSurfer subject folders.
- confirm final path layout for `matlab-utils` atlas resources and shell scripts.
- decide whether to keep the thin `hb_corticalparc` wrapper or expose lower-level `hb_aparcfsavg2subj` inputs directly.

## rs-fMRI surface projection and FC construction

- decide whether demo 02 should remain a thin wrapper around the original `BuildFC_SurfaceSUBJ` call or be generalized to direct inputs.
- document required volume inputs, registration transforms, FreeSurfer surfaces, and subject-space annotations.
- confirm output naming for parcellated time series and FC matrices.

## PET surface projection and parcellation

- decide whether demo 03 should remain a thin wrapper around the original `ParcellateTauPet_SurfaceSUBJ` / `ParcellateAmyPet_SurfaceSUBJ` calls or be generalized to direct inputs.
- document PET image, PET-associated T1 image, FreeSurfer anatomical target, and output parcel-vector format.
- confirm optional GIFTI output behavior.

## regional FC-PET fits

- extract exact regional model code path from `run_fitlms.m`.
- retain exact orthogonalization call used for subject FC relative to template FC.
- retain exact normalization order for template FC and orthogonalized subject FC.
- retain exact corrected R2 output from `fitlm`.
- retain exact seed parcel exclusion.

## hybrid FC construction

- extract exact `getMixFcR` code path from `run_fitlms.m`.
- confirm beta use, normalization sequence, and original vs orthogonalized subject FC handling.
- confirm output matrix orientation.

## whole-brain OLS

- extract exact `fitlhrh` and whole-brain model code paths from `run_fitlms.m`.
- retain exact design-matrix construction.
- retain hemisphere splitting and averaging.
- retain predictor normalization and corrected R2 output.

## canonical PET maps

- use exact `hb_tp2tpp`-based implementation used by `script_two.m`.
- retain exact GMM fitting, regularization, component ordering, and output structures.
- document subject groups included for tau-PET and Aβ-PET maps.

## canonical vs hybrid model comparison

- extract exact regression design from `run_fitlms.m` for canonical maps alone, hybrid FC alone, and combined models.
- retain normalization of PET-map regressors and corrected R2 comparison.

## degree-preserving FC nulls

- use exact `hb_graph_shuffle_v0` call used in `run_fitlms.m`.
- document required dependency and input FC preprocessing.
- retain random seed handling and number of null matrices.

## degree- and strength-preserving FC nulls

- use exact `fcn_randomize_str_hb` call used in `run_fitlms.m`.
- retain annealing parameters and starting graph construction.
- document required external dependency.

## Moran surrogate tau-PET maps

- add exact Moran spectral randomization implementation from the revised analysis code.
- document spatial weights/geodesic distance input and number of surrogate maps.
- retain random seed handling.

## ridge-CV held-out parcels

- add exact revised code for outer and inner CV construction.
- retain `Kouter`, `Kinner`, `foldSeeds`, network-stratification, lambda grid, and selection criterion.
- retain out-of-sample R2 calculation.

## split-half beta stability

- add exact revised code for split-half repetitions.
- retain split seed, network-stratification, lambda handling, and beta-vector correlation details.
- retain exclusion of intercept and hemisphere averaging.

## longitudinal follow-up tau-PET

- extract exact baseline-to-follow-up setup from `script_two.m` and `run_fitlms.m`.
- retain use of precomputed baseline hybrid-FC weights for follow-up PET sessions.
- retain matched-subject handling and output structure.
