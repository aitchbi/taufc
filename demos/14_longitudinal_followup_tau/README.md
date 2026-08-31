# demo: longitudinal follow-up tau-PET analysis

## purpose

This demo documents how to run the longitudinal follow-up tau-PET analysis module.

## manuscript connection

Fig. 6 and Fig. S18.

## inputs

- `baseline_hybrid_fc: P x P baseline hybrid FC matrix`
- `baseline_template_fc: P x P baseline template FC matrix`
- `followup_tau_pet: P x 1 follow-up tau-PET vector`

## outputs

- `corrected R2 for follow-up tau-PET using baseline FC representations`

## status

The exact manuscript implementation will be added to the corresponding `src/` function. this demo intentionally does not include a simplified replacement implementation.

## how to use

1. run `startup` from the repository root.
2. replace the input block in the demo script with your own parcellated data.
3. run the demo script.
