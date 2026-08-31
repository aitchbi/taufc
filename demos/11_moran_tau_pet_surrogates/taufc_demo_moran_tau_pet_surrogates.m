%-prepare workspace.
%--------------------------------------------------------------------------
clear; clc;

%-define inputs.
%--------------------------------------------------------------------------
% replace this block with your own data before running the demo.
% pet: P x 1 tau-PET vector
% spatial_weights: P x P spatial weights or distance-derived matrix
% external Moran randomization dependency

%-run Moran surrogate tau-PET maps.
%--------------------------------------------------------------------------
% this call will run after the exact implementation has been added.
surrogate_pet = taufc_func_run_moran_tau_surrogates(pet, spatial_weights);

%-inspect outputs.
%--------------------------------------------------------------------------
disp(size(surrogate_pet));
