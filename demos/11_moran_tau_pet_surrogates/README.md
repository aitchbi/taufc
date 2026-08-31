# demo: Moran surrogate tau-PET maps

## purpose

This demo documents how to run the Moran surrogate tau-PET maps module.

## manuscript connection

Fig. 1 and Fig. S1.

## inputs

- `pet: P x 1 tau-PET vector`
- `spatial_weights: P x P spatial weights or distance-derived matrix`
- `external Moran randomization dependency`

## outputs

- `surrogate_pet: P x nSurrogates surrogate PET maps`

## status

The exact manuscript implementation will be added to the corresponding `src/` function. this demo intentionally does not include a simplified replacement implementation.

## how to use

1. run `startup` from the repository root.
2. replace the input block in the demo script with your own parcellated data.
3. run the demo script.
