# demo: whole-brain OLS model comparison

## purpose

This demo documents how to run the whole-brain OLS model comparison module.

## manuscript connection

Fig. 2 and Fig. S2.

## inputs

- `fc_matrix: P x P FC representation`
- `pet: P x 1 tau-PET vector`
- `optional hemisphere labels`

## outputs

- `corrected R2 for whole-brain OLS model`

## status

The exact manuscript implementation will be added to the corresponding `src/` function. this demo intentionally does not include a simplified replacement implementation.

## how to use

1. run `startup` from the repository root.
2. replace the input block in the demo script with your own parcellated data.
3. run the demo script.
