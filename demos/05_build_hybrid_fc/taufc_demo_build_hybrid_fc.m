%-prepare workspace.
%--------------------------------------------------------------------------
clear; clc;

%-define inputs.
%--------------------------------------------------------------------------
% replace this block with your own data before running the demo.
% subject_fc: P x P subject-level FC matrix
% template_fc: P x P template FC matrix
% beta_template: P x 1 regional template-FC weights
% beta_subject: P x 1 regional subject-FC weights

%-run hybrid FC construction.
%--------------------------------------------------------------------------
% this call will run after the exact implementation has been added.
hybrid_fc = taufc_func_build_hybrid_fc(subject_fc, template_fc, beta_template, beta_subject);

%-inspect outputs.
%--------------------------------------------------------------------------
disp(size(hybrid_fc));
