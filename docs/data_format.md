# data format

This repository does not distribute BioFINDER-2, ADNI, or A4 data.

Most demos assume that users start from parcellated data rather than raw imaging files.

## common variables

- `subject_fc`: `P x P` subject-level FC matrix.
- `template_fc`: `P x P` group-level template FC matrix.
- `pet`: `P x 1` parcellated PET vector for one subject.
- `pet_matrix`: `P x N` parcellated PET matrix for `N` subjects.
- `network_labels`: `P x 1` vector assigning parcels to canonical networks.
- `distance_matrix` or `spatial_weights`: `P x P` spatial distance or weight matrix for Moran surrogates.

`P` is the number of cortical parcels at a given atlas resolution.

## conventions

- FC matrices should be symmetric.
- diagonal FC entries should generally be set to zero before modelling.
- negative FC entries were set to zero in the manuscript analyses.
- positive FC values were Fisher z transformed in the manuscript analyses.
- PET vectors should be sampled in the same subject-space parcellation as the FC matrices.
