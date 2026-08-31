# demo: nested ridge-CV held-out parcel prediction

## purpose

This demo documents how to run the nested ridge-CV held-out parcel prediction module.

## manuscript connection

Fig. 2 and Fig. S4.

## inputs

- `fc_matrix: P x P FC representation`
- `pet: P x 1 tau-PET vector`
- `network_labels: P x 1 network labels`

## outputs

- `out-of-sample R2`
- `held-out predictions`
- `selected lambda values`

## status

The exact manuscript implementation will be added to the corresponding `src/` function. this demo intentionally does not include a simplified replacement implementation.

## how to use

1. run `startup` from the repository root.
2. replace the input block in the demo script with your own parcellated data.
3. run the demo script.
