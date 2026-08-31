# demo: hybrid FC construction

## purpose

This demo documents how to run the hybrid FC construction module.

## manuscript connection

Fig. 2 framework.

## inputs

- `subject_fc: P x P subject-level FC matrix`
- `template_fc: P x P template FC matrix`
- `beta_template: P x 1 regional template-FC weights`
- `beta_subject: P x 1 regional subject-FC weights`

## outputs

- `hybrid_fc: P x P matrix`

## status

The exact manuscript implementation will be added to the corresponding `src/` function. this demo intentionally does not include a simplified replacement implementation.

## how to use

1. run `startup` from the repository root.
2. replace the input block in the demo script with your own parcellated data.
3. run the demo script.
