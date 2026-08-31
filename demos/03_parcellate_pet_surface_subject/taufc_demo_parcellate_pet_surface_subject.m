%-prepare workspace.
%--------------------------------------------------------------------------
clear; clc;

%-set paths.
%--------------------------------------------------------------------------
repo_dir = fileparts(fileparts(fileparts(mfilename('fullpath'))));
addpath(genpath(fullfile(repo_dir, 'src')));
addpath(genpath(fullfile(repo_dir, 'src', 'utils', 'utils_tmp')));

% clone matlab-utils from:
% https://github.com/aitchbi/matlab-utils
% then set this path to your local copy.
dir_matlab_utils = '';

if isempty(dir_matlab_utils)

    error('taufc:missingpath', 'set dir_matlab_utils before running this demo.');
end

addpath(genpath(dir_matlab_utils));

%-define inputs.
%--------------------------------------------------------------------------
% this mirrors the PET parcellation options in the original script_one.m.
% set which_pet to 'Tau' or 'Amy'.

ids = 1;
which_session = 'sess1---rsfs1365';
which_atlas = 'Schaefer400Yeo7';
which_pet = 'Tau';

%-run surface projection and PET parcellation.
%--------------------------------------------------------------------------
outs = taufc_func_parcellate_pet_surface_subject(which_pet, which_session, ids, which_atlas);

%-inspect outputs.
%--------------------------------------------------------------------------
disp(outs);
