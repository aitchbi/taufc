%-prepare workspace.
%--------------------------------------------------------------------------
clear; clc;

%-set paths.
%--------------------------------------------------------------------------
repo_dir = fileparts(fileparts(fileparts(mfilename('fullpath'))));
addpath(genpath(fullfile(repo_dir, 'src')));

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
% this demo requires real FreeSurfer outputs and atlas resources.
% replace the values below with local paths before running.

param = struct;

param.ID = 'set-subject-id';
param.WhichAtlas = 'Schaefer400Yeo7';
param.dir_subjs = 'set-freesurfer-subjects-dir';
param.dir_freesurfer = 'set-freesurfer-installation-dir';
param.dir_fsaverage_hb = 'set-fsaverage-hb-dir';
param.dir_hbfssh = 'set-hbfssh-dir';
param.parallel_nowhere = true;
param.parallel_subjs = false;
param.OverWriteExistingRois = false;
param.JustGetRoisName = false;

%-run subject-space parcellation.
%--------------------------------------------------------------------------
% this mirrors the BuildParcels_surface workflow used in the original
% script_one.m pipeline.

param = taufc_func_build_subject_space_schaefer_parcellation(param);

%-inspect outputs.
%--------------------------------------------------------------------------
disp(param.f_surfrois);
