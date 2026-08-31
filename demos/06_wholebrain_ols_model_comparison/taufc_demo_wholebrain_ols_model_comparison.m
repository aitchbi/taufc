%-prepare workspace.
%--------------------------------------------------------------------------
clear; clc;

%-define inputs.
%--------------------------------------------------------------------------
% replace this block with your own data before running the demo.
% fc_matrix: P x P FC representation
% pet: P x 1 tau-PET vector
% optional hemisphere labels

%-run whole-brain OLS model comparison.
%--------------------------------------------------------------------------
% this call will run after the exact implementation has been added.
results = taufc_func_run_wholebrain_ols(fc_matrix, pet);

%-inspect outputs.
%--------------------------------------------------------------------------
disp(results);
