%-initialize.
%--------------------------------------------------------------------------
clear
clc
close all

repo_root = fileparts(fileparts(fileparts(mfilename('fullpath'))));

addpath(genpath(fullfile(repo_root, 'src')));

assert(exist('hb_surfparc_project_volume_to_surface', 'file') ~= 0, ...
    ['hb_surfparc_project_volume_to_surface.m not found. ',...
    'add the surfparc repo to MATLAB path before running this demo.']);

assert(exist('hb_surfparc_extract_parcel_values', 'file') ~= 0, ...
    ['hb_surfparc_extract_parcel_values.m not found. add the surfparc ', ...
    'repository to MATLAB path before running this demo.']);

assert(exist('taufc_func_build_fc_from_timeseries', 'file') ~= 0, ...
    'taufc_func_build_fc_from_timeseries.m not found. ', ...
    'check that src/connectivity is on the MATLAB path.');

assert(exist('taufc_func_verify_freesurfer_space', 'file') ~= 0, ...
    'taufc_func_verify_freesurfer_space.m not found. ', ...
    'check that src/utils is on the MATLAB path.');

%-user inputs.
%--------------------------------------------------------------------------
% edit these paths before running.

dir_subject_fs = '/absolute/path/to/freesurfer/subject';

f_rsfmri = '/absolute/path/to/rsfmri_registered_to_freesurfer.nii.gz';

dir_freesurfer = '/absolute/path/to/freesurfer';

WhichAtlas = 'Schaefer100Yeo7';

dir_output = fullfile(dir_subject_fs, 'HB');

f_reg = '';
%
% leave f_reg empty only if the rs-fMRI volume is voxel/header matched to
% the subject's FreeSurfer reference volume and can be sampled using
% --regheader. if f_reg is empty, the projection uses --regheader. in
% that case, the rs-fMRI file must be voxel/header matched to the subject's
% FreeSurfer reference volume. if the rs-fMRI has a different voxel grid,
% provide an explicit FreeSurfer registration file in f_reg instead.

f_fs_ref = fullfile(dir_subject_fs, 'mri', 'ribbon.nii');

assert(~startsWith(dir_subject_fs, '/absolute/path'), ...
    'edit dir_subject_fs before running this demo.');

assert(~startsWith(f_rsfmri, '/absolute/path'), ...
    'edit f_rsfmri before running this demo.');

assert(~startsWith(dir_freesurfer, '/absolute/path'), ...
    'edit dir_freesurfer before running this demo.');

%-input annotation files from demo 01.
%--------------------------------------------------------------------------
atlas_name = lower(WhichAtlas);

f_annot_lh = fullfile(dir_output, 'schaefer', ['lh.', atlas_name, '.annot']);
f_annot_rh = fullfile(dir_output, 'schaefer', ['rh.', atlas_name, '.annot']);

assert(exist(f_annot_lh, 'file') ~= 0, ...
    'left-hemisphere annotation file not found. run demo 01 first: %s', f_annot_lh);

assert(exist(f_annot_rh, 'file') ~= 0, ...
    'right-hemisphere annotation file not found. run demo 01 first: %s', f_annot_rh);

%-verify rs-fMRI space before surface projection.
%--------------------------------------------------------------------------
if isempty(f_reg)
    
    out_space = taufc_func_verify_freesurfer_space( ...
        f_rsfmri, ...
        dir_subject_fs, ...
        'ReferenceFile', f_fs_ref);
else
    
    assert(exist(f_reg, 'file') ~= 0, ...
        'registration file not found: %s', f_reg);
    
    out_space = [];
end

%-project rs-fMRI volume to subject surface.
%--------------------------------------------------------------------------
dir_surface = fullfile(dir_output, 'surface');

out_surf = hb_surfparc_project_volume_to_surface( ...
    f_rsfmri, ...
    dir_subject_fs, ...
    'OutputDir', dir_surface, ...
    'OutputPrefix', ['rsfmri_', atlas_name], ...
    'DirFreeSurfer', dir_freesurfer, ...
    'RegFile', f_reg, ...
    'ProjFrac', 0.5);

%-extract parcel time series.
%--------------------------------------------------------------------------
dir_fc = fullfile(dir_output, 'fc');

if ~exist(dir_fc, 'dir')
    
    mkdir(dir_fc);
end

f_timeseries = fullfile(dir_fc, ['rsfmri_', atlas_name, '_parcel_timeseries.mat']);

out_values = hb_surfparc_extract_parcel_values( ...
    out_surf.f_surface.lh, ...
    out_surf.f_surface.rh, ...
    f_annot_lh, ...
    f_annot_rh, ...
    'OutputFile', f_timeseries);

parcel_ts = out_values.parcel_values;

%-build FC.
%--------------------------------------------------------------------------
[FC, out_fc] = taufc_func_build_fc_from_timeseries( ...
    parcel_ts, ...
    'ZeroDiag', true, ...
    'PositiveOnly', true, ...
    'FisherZ', true);

%-save outputs.
%--------------------------------------------------------------------------
f_fc = fullfile(dir_fc, ['rsfmri_', atlas_name, '_fc.mat']);

save(f_fc, ...
    'FC', ...
    'out_fc', ...
    'out_surf', ...
    'out_values', ...
    'out_space', ...
    'parcel_ts', ...
    'f_rsfmri', ...
    'f_annot_lh', ...
    'f_annot_rh', ...
    'WhichAtlas');

fprintf('\nfile saved: %s\n', f_timeseries);
fprintf('file saved: %s\n', f_fc);

fprintf('\ndemo done.\n');