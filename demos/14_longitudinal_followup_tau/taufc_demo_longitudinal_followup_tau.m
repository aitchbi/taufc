%-prepare workspace.
%--------------------------------------------------------------------------
clear; clc;

%-define inputs.
%--------------------------------------------------------------------------
% replace this block with your own data before running the demo.
% baseline_hybrid_fc: P x P baseline hybrid FC matrix
% baseline_template_fc: P x P baseline template FC matrix
% followup_tau_pet: P x 1 follow-up tau-PET vector

%-run longitudinal follow-up tau-PET analysis.
%--------------------------------------------------------------------------
% this call will run after the exact implementation has been added.
results = taufc_func_run_longitudinal_followup_tau(baseline_hybrid_fc, baseline_template_fc, followup_tau_pet);

%-inspect outputs.
%--------------------------------------------------------------------------
disp(results);
