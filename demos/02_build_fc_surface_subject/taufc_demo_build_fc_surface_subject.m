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
% this mirrors the BuildFC_SurfaceSUBJ option in the original script_one.m.
% replace these values with local subject/session identifiers and atlas name.

ids = 1;
which_session = 'sess1---rsfs1365';
which_atlas = 'Schaefer400Yeo7';

%-run surface projection and FC construction.
%--------------------------------------------------------------------------
outs = taufc_func_build_fc_surface_subject(which_session, ids, which_atlas);

%-inspect outputs.
%--------------------------------------------------------------------------
disp(outs);
