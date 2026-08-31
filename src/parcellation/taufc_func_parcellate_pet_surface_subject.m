function outs = taufc_func_parcellate_pet_surface_subject(which_pet, which_session, ids, which_atlas)
% project and parcellate subject-space PET data on cortical surfaces.
%
% this is a thin wrapper around the original ParcellateTauPet_SurfaceSUBJ
% and ParcellateAmyPet_SurfaceSUBJ workflows in script_one.m. it expects the
% original helper utilities and local path adapters to be available on the
% MATLAB path.
%
% inputs:
%   which_pet: 'Tau' or 'Amy'
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

which_pet = char(which_pet);

%-select original workflow.
%--------------------------------------------------------------------------
switch lower(which_pet)

    case {'tau', 'taupet', 'tau-pet'}

        do_what = 'ParcellateTauPet_SurfaceSUBJ';

    case {'amy', 'amyloid', 'abeta', 'beta-amyloid', 'amyloidpet', 'amyloid-pet'}

        do_what = 'ParcellateAmyPet_SurfaceSUBJ';

    otherwise

        error('taufc:unknownpet', 'which_pet should be ''Tau'' or ''Amy''.');
end

%-run original workflow.
%--------------------------------------------------------------------------
outs = biofinder_main(do_what, which_session, ids, which_atlas);
end
