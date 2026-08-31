# demo: canonical versus hybrid model comparison

## purpose

This demo documents how to run the canonical versus hybrid model comparison module.

## manuscript connection

Fig. 3 and Fig. S11.

## inputs

- `pet: P x 1 tau-PET vector`
- `hybrid_fc: P x P hybrid FC matrix`
- `canonical_maps: structure with off-target and on-target PET maps`

## outputs

- `corrected R2 for each canonical, hybrid, and combined model`

## status

The exact manuscript implementation will be added to the corresponding `src/` function. this demo intentionally does not include a simplified replacement implementation.

## how to use

1. run `startup` from the repository root.
2. replace the input block in the demo script with your own parcellated data.
3. run the demo script.
