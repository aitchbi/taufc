%-prepare workspace.
%--------------------------------------------------------------------------
clear; clc;

%-define inputs.
%--------------------------------------------------------------------------
% replace this block with your own data before running the demo.
% subject_fc: P x P subject-level FC matrix
% external degree-preserving null-model dependency

%-run degree-preserving FC null model.
%--------------------------------------------------------------------------
% this call will run after the exact implementation has been added.
null_fc = taufc_func_run_degree_preserving_fc_null(subject_fc);

%-inspect outputs.
%--------------------------------------------------------------------------
disp(size(null_fc));
