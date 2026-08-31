%-prepare workspace.
%--------------------------------------------------------------------------
clear; clc;

%-define inputs.
%--------------------------------------------------------------------------
% replace this block with your own data before running the demo.
% pet: P x 1 tau-PET vector
% hybrid_fc: P x P hybrid FC matrix
% canonical_maps: structure with off-target and on-target PET maps

%-run canonical versus hybrid model comparison.
%--------------------------------------------------------------------------
% this call will run after the exact implementation has been added.
results = taufc_func_run_canonical_pet_models(pet, hybrid_fc, canonical_maps);

%-inspect outputs.
%--------------------------------------------------------------------------
disp(results);
