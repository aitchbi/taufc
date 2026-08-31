# demo: regional FC-PET fits

## purpose

This demo documents how to run the regional FC-PET fits module.

## manuscript connection

Fig. 1 and Fig. S1.

## inputs

- `subject_fc: P x P subject-level FC matrix`
- `template_fc: P x P template FC matrix`
- `pet: P x 1 parcellated tau-PET vector`

## outputs

- `corrected R2 for template FC alone`
- `corrected R2 for template FC + subject FC`
- `regional beta coefficients used for hybrid FC construction`

## status

The exact manuscript implementation will be added to the corresponding `src/` function. this demo intentionally does not include a simplified replacement implementation.

## how to use

1. run `startup` from the repository root.
2. replace the input block in the demo script with your own parcellated data.
3. run the demo script.
