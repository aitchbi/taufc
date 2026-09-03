%-initialize.
%--------------------------------------------------------------------------
clear
clc
close all

repo_root = fileparts(fileparts(fileparts(mfilename('fullpath'))));

addpath(genpath(fullfile(repo_root, 'src')));

assert(exist('hb_surfparc_project_volume_to_surface', 'file') ~= 0, ...
    ['hb_surfparc_project_volume_to_surface.m not found. add the surfparc ', ...
    'repository to the MATLAB path before running this demo.']);

assert(exist('hb_surfparc_extract_parcel_values', 'file') ~= 0, ...
    ['hb_surfparc_extract_parcel_values.m not found. add the surfparc ', ...
    'repository to the MATLAB path before running this demo.']);

assert(exist('taufc_func_verify_freesurfer_space', 'file') ~= 0, ...
    'taufc_func_verify_freesurfer_space.m not found. check that src/utils is on the MATLAB path.');

%-user inputs.
%--------------------------------------------------------------------------
% edit these paths before running.

dir_subject_fs = '/absolute/path/to/freesurfer/subject';

f_pet = '/absolute/path/to/pet_registered_to_freesurfer.nii.gz';

dir_freesurfer = '/absolute/path/to/freesurfer';

WhichAtlas = 'Schaefer100Yeo7';

dir_output = fullfile(dir_subject_fs, 'HB');

% leave empty only if the PET volume is voxel/header matched to the
% subject's FreeSurfer reference volume and can be sampled using --regheader.
f_reg = '';

% if f_reg is empty, the projection uses --regheader. in that case, the PET
% file must be voxel/header matched to the subject's FreeSurfer reference
% volume. if the PET has a different voxel grid, provide an explicit
% FreeSurfer registration file in f_reg instead.

f_fs_ref = fullfile(dir_subject_fs, 'mri', 'ribbon.nii');

assert(~startsWith(dir_subject_fs, '/absolute/path'), ...
    'edit dir_subject_fs before running this demo.');

assert(~startsWith(f_pet, '/absolute/path'), ...
    'edit f_pet before running this demo.');

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

%-verify PET space before surface projection.
%--------------------------------------------------------------------------
if isempty(f_reg)
    
    out_space = taufc_func_verify_freesurfer_space( ...
        f_pet, ...
        dir_subject_fs, ...
        'ReferenceFile', f_fs_ref);
else
    
    assert(exist(f_reg, 'file') ~= 0, ...
        'registration file not found: %s', f_reg);
    
    out_space = [];
end

%-project PET volume to subject surface.
%--------------------------------------------------------------------------
dir_surface = fullfile(dir_output, 'surface');

out_surf = hb_surfparc_project_volume_to_surface( ...
    f_pet, ...
    dir_subject_fs, ...
    'OutputDir', dir_surface, ...
    'OutputPrefix', ['pet_', atlas_name], ...
    'DirFreeSurfer', dir_freesurfer, ...
    'RegFile', f_reg, ...
    'ProjFrac', 0.5);

%-extract parcel PET values.
%--------------------------------------------------------------------------
dir_pet = fullfile(dir_output, 'pet');

if ~exist(dir_pet, 'dir')
    
    mkdir(dir_pet);
end

f_parcel_pet = fullfile(dir_pet, ['pet_', atlas_name, '_parcel_values.mat']);

out_values = hb_surfparc_extract_parcel_values( ...
    out_surf.f_surface.lh, ...
    out_surf.f_surface.rh, ...
    f_annot_lh, ...
    f_annot_rh, ...
    'OutputFile', f_parcel_pet);

parcel_pet = out_values.parcel_values;

%-save outputs.
%--------------------------------------------------------------------------
f_pet_out = fullfile(dir_pet, ['pet_', atlas_name, '_parcellated.mat']);

save(f_pet_out, ...
    'parcel_pet', ...
    'out_surf', ...
    'out_values', ...
    'out_space', ...
    'f_pet', ...
    'f_annot_lh', ...
    'f_annot_rh', ...
    'WhichAtlas');

fprintf('\nfile saved: %s\n', f_parcel_pet);
fprintf('file saved: %s\n', f_pet_out);

fprintf('\ndemo done.\n');