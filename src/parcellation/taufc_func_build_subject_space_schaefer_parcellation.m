function param = taufc_func_build_subject_space_schaefer_parcellation(param)
% run subject-space Schaefer parcellation.
%
% this is a thin wrapper around hb_corticalparc, matching the
% BuildParcels_surface workflow used in the original script_one.m pipeline.
%
% required fields in param:
%   ID
%   WhichAtlas
%   dir_subjs
%   dir_freesurfer
%   dir_fsaverage_hb
%   dir_hbfssh
%
% output:
%   param with subject-space parcellation filenames in param.f_surfrois

%-check inputs.
%--------------------------------------------------------------------------
required_fields = { ...
    'ID', ...
    'WhichAtlas', ...
    'dir_subjs', ...
    'dir_freesurfer', ...
    'dir_fsaverage_hb', ...
    'dir_hbfssh'};

for i_field = 1:numel(required_fields)

    this_field = required_fields{i_field};

    assert(isfield(param, this_field), 'missing param.%s', this_field);
end

if ~isfield(param, 'parallel_nowhere')
    param.parallel_nowhere = true;
end

if ~isfield(param, 'parallel_subjs')
    param.parallel_subjs = false;
end

if ~isfield(param, 'OverWriteExistingRois')
    param.OverWriteExistingRois = false;
end

if ~isfield(param, 'JustGetRoisName')
    param.JustGetRoisName = false;
end

%-run parcellation.
%--------------------------------------------------------------------------
param = hb_corticalparc(param, 'JustGetSurfaceParcellation', true);
end
