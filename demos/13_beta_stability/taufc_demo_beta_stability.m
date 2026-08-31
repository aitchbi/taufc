%-prepare workspace.
%--------------------------------------------------------------------------
clear; clc;

%-define inputs.
%--------------------------------------------------------------------------
% replace this block with your own data before running the demo.
% fc_matrix: P x P FC representation
% pet: P x 1 tau-PET vector
% network_labels: P x 1 network labels

%-run split-half beta stability.
%--------------------------------------------------------------------------
% this call will run after the exact implementation has been added.
results = taufc_func_beta_stability_split_half(fc_matrix, pet, network_labels);

%-inspect outputs.
%--------------------------------------------------------------------------
disp(results);
