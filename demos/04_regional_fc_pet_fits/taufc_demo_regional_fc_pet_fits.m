%-prepare workspace.
%--------------------------------------------------------------------------
clear; clc;

%-define inputs.
%--------------------------------------------------------------------------
% replace this block with your own data before running the demo.
% subject_fc: P x P subject-level FC matrix
% template_fc: P x P template FC matrix
% pet: P x 1 parcellated tau-PET vector

%-run regional FC-PET fits.
%--------------------------------------------------------------------------
% this call will run after the exact implementation has been added.
results = taufc_func_run_regional_fc_pet_fits(subject_fc, template_fc, pet);

%-inspect outputs.
%--------------------------------------------------------------------------
disp(results);
