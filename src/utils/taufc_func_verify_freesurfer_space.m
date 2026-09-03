function out = taufc_func_verify_freesurfer_space(f_vol, dir_subject_fs, varargin)
% verify that an input volume is in the same voxel/header space as FreeSurfer.
%
% this is a strict check intended for --regheader workflows.

p = inputParser;

addRequired(p, 'f_vol', @(x) ischar(x) || isstring(x));
addRequired(p, 'dir_subject_fs', @(x) ischar(x) || isstring(x));

addParameter(p, 'ReferenceFile', '', @(x) ischar(x) || isstring(x));
addParameter(p, 'DuplicateThenUnzip', true, @(x) islogical(x) && isscalar(x));

parse(p, f_vol, dir_subject_fs, varargin{:});

f_vol = char(p.Results.f_vol);
dir_subject_fs = char(p.Results.dir_subject_fs);
f_ref = char(p.Results.ReferenceFile);

assert(exist(f_vol, 'file') ~= 0, ...
    'input volume not found: %s', f_vol);

assert(exist(dir_subject_fs, 'dir') ~= 0, ...
    'FreeSurfer subject directory not found: %s', dir_subject_fs);

assert(exist('hb_nii_verify_space_match_v2', 'file') ~= 0, ...
    ['hb_nii_verify_space_match_v2.m not found. add ', ...
    'https://github.com/aitchbi/matlab-utils to the MATLAB path.']);

if isempty(f_ref)
    
    f_ref = fullfile(dir_subject_fs, 'mri', 'ribbon.nii');
end

assert(exist(f_ref, 'file') ~= 0, ...
    ['FreeSurfer reference NIfTI not found: %s\n', ...
    'create this file from ribbon.mgz, or pass ReferenceFile explicitly.'], f_ref);

[sts, h1, h2, errors] = hb_nii_verify_space_match_v2( ...
    f_vol, ...
    f_ref, ...
    'DuplicateThenUnzip', p.Results.DuplicateThenUnzip, ...
    'ThrowError', false);

if ~sts
    
    fprintf('\nspace mismatch between input volume and FreeSurfer reference:\n');
    fprintf('input volume: %s\n', f_vol);
    fprintf('reference:    %s\n', f_ref);
    
    disp(errors(:))
    
    error(['input volume is not voxel/header matched to the FreeSurfer ', ...
        'reference volume. use a correctly registered volume, or provide ', ...
        'an explicit FreeSurfer registration file instead of --regheader.']);
end

out = struct;

out.status = sts;
out.f_vol = f_vol;
out.f_ref = f_ref;
out.h_vol = h1;
out.h_ref = h2;
out.errors = errors;

end