function outs = taufc_func_build_fc_surface_subject(which_session, ids, which_atlas)
% build subject-space surface FC from rs-fMRI.
%
% this is a thin wrapper around the original BuildFC_SurfaceSUBJ workflow in
% script_one.m. it expects the original helper utilities and local path
% adapters to be available on the MATLAB path.
%
% inputs:
%   which_session: session/run label used by the local data adapter
%   ids: subject index or vector of subject indices
%   which_atlas: Schaefer atlas name or one-element cell array
%
% output:
%   outs: output returned by biofinder_main

%-check inputs.
%--------------------------------------------------------------------------
if ischar(which_atlas) || isstring(which_atlas)

    which_atlas = {char(which_atlas)};
end

assert(iscell(which_atlas), 'which_atlas should be a character vector or cell array.');

%-run original workflow.
%--------------------------------------------------------------------------
do_what = 'BuildFC_SurfaceSUBJ';

outs = biofinder_main(do_what, which_session, ids, which_atlas);
end
