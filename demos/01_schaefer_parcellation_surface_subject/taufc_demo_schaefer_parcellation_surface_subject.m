%-initialize.
%--------------------------------------------------------------------------
clear
clc
close all

repo_root = fileparts(fileparts(fileparts(mfilename('fullpath'))));

addpath(genpath(fullfile(repo_root, 'src')));

assert(exist('hb_surfparc_warp_atlas_to_subject', 'file') ~= 0, ...
    ['hb_surfparc_warp_atlas_to_subject.m not found. add the surfparc ', ...
    'repository to the MATLAB path before running this demo.']);

%-user inputs.
%--------------------------------------------------------------------------
% edit these paths before running.

dir_subject_fs = '/absolute/path/to/freesurfer/subject';

% fsaverage_hb directory from:
% https://github.com/aitchbi/matlab-utils/tree/main/misc/freesurfer/fsaverage_hb
dir_fsaverage_hb = '/absolute/path/to/matlab-utils/misc/freesurfer/fsaverage_hb';

dir_freesurfer = '/absolute/path/to/freesurfer'; 
% eg:
% /Applications/freesurfer/7.1.1

WhichAtlas = 'Schaefer100Yeo7';
%
% 'Schaefer<*>Yeo7'
% with <*>: 100, 200, 300, ..., or 1000

% by default, outputs are written to dir_subject_fs/HB/. use this option
% when the FreeSurfer subject directory is not writable.
dir_output = fullfile(dir_subject_fs, 'HB');

assert(~startsWith(dir_subject_fs, '/absolute/path'), ...
    'edit dir_subject_fs before running this demo.');

assert(~startsWith(dir_fsaverage_hb, '/absolute/path'), ...
    'edit dir_fsaverage_hb before running this demo.');

assert(~startsWith(dir_freesurfer, '/absolute/path'), ...
    'edit dir_freesurfer before running this demo.');

%-warp atlas to subject surface.
%--------------------------------------------------------------------------
out_parc = hb_surfparc_warp_atlas_to_subject( ...
    dir_subject_fs, ...
    dir_fsaverage_hb, ...
    WhichAtlas, ...
    'OutputDir', dir_output, ...
    'DirFreeSurfer', dir_freesurfer);

fprintf('\ndemo done.\n');