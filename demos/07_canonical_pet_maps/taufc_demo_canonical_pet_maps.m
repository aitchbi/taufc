%-prepare workspace.
%--------------------------------------------------------------------------
clear; clc;

%-define inputs.
%--------------------------------------------------------------------------
% replace this block with your own data before running the demo.
% pet_matrix: P x N PET matrix

%-run canonical PET map derivation.
%--------------------------------------------------------------------------
% this call will run after the exact implementation has been added.
canonical = taufc_func_build_canonical_pet_maps(pet_matrix);

%-inspect outputs.
%--------------------------------------------------------------------------
disp(canonical);
