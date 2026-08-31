# demo: canonical PET map derivation

## purpose

This demo documents how to run the canonical PET map derivation module.

## manuscript connection

Fig. 3 and Fig. S8-S10.

## inputs

- `pet_matrix: P x N PET matrix`

## outputs

- `canonical off-target PET map`
- `canonical on-target PET map`
- `Gaussian mixture parameters`

## status

The exact manuscript implementation will be added to the corresponding `src/` function. this demo intentionally does not include a simplified replacement implementation.

## how to use

1. run `startup` from the repository root.
2. replace the input block in the demo script with your own parcellated data.
3. run the demo script.
