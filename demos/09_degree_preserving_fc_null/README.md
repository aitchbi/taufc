# demo: degree-preserving FC null model

## purpose

This demo documents how to run the degree-preserving FC null model module.

## manuscript connection

Fig. 1 and Fig. S1.

## inputs

- `subject_fc: P x P subject-level FC matrix`
- `external degree-preserving null-model dependency`

## outputs

- `null_fc: P x P degree-preserving null FC matrix`

## status

The exact manuscript implementation will be added to the corresponding `src/` function. this demo intentionally does not include a simplified replacement implementation.

## how to use

1. run `startup` from the repository root.
2. replace the input block in the demo script with your own parcellated data.
3. run the demo script.
