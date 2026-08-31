function [S, F, lbls] = biofinder_pet2petfsparc(type, f_pet, f_pett1, f_fsrib, f_fst1, f_parc, d_fsl, ofnames, FS, varargin)
% BIOFINDER_PET2PETFSPARC surface-based parcellation of PET maps in subject
% space.
%
% dependencies:
%   .SPM12 toolbox
%   .ANTs
%   .github/aitchbi/matlab-utils
%
% h behjat

d = inputParser;

addParameter(d, 'WhichPet', ''); 

addParameter(d, 'SaveGifti', false); 

addParameter(d, 'JustGetGifti', false); 

parse(d,varargin{:});

opts = d.Results;

if opts.JustGetGifti

    opts.SaveGifti = true;
end

if isempty(opts.WhichPet)
    
    tag_pet = '';
else
    
    tag_pet = [opts.WhichPet, '-'];
end

F_cleanup = [];

%-[1] reslice PET to match FS ribbon.
%--------------------------------------------------------------------------
F = struct;

F.fsrib = f_fsrib;

F.fst1 = f_fst1;

F.fsl = d_fsl;

F.pet = f_pet;

F.pett1 = f_pett1;

if exist('ofnames', 'var')

    F.pett1brain = ofnames.f_pett1brain;
    
    F.petfs = ofnames.f_petfs;
    
    F.pett1brainfs = ofnames.f_pett1brainfs;
    
    F.pet2fs = ofnames.f_pet2fs;
    
    f_petfs = F.petfs;
else
    error('extend');
end

if opts.JustGetGifti

    f_gii = getfgii(f_petfs, FS.surfspace);
    
    d1 = exist(f_gii.lh, 'file');
    
    d2 = exist(f_gii.rh, 'file');
    
    if d1 && d2
    
        S.f_gii = f_gii;
        
        S.f_gii_existed = true;
        
        return;
    
    else
    
        S.f_gii_existed = false;
    end
end

F_cleanup = reslicetomatchfs(F, F_cleanup, tag_pet);

[d, msg] = hb_nii_verify_overlap(f_petfs, f_fsrib, 95, 'second');

if not(d)

    fprintf(msg);
    
    fprinff('\n.ribbon: %s', f_fsrib);
    
    fprinff('\n.%sPET: %s', tag_pet, f_petfs);
    
    error('Fishy overlap between ribbon and %sPET.', tag_pet);
end

assert(isequal(f_fsrib, FS.f_ribbon));

%-[2] extract PET values.
%--------------------------------------------------------------------------
assert(isequal(type, 'surface'));

[S, F_cleanup] = getpetsurf(f_petfs, FS, tag_pet, opts.SaveGifti, F_cleanup);

if opts.JustGetGifti

    cleanup(F_cleanup);
    
    lbls = [];
    
    return;
end

%-[3] get avg PET values in each volumetric parcel.
%--------------------------------------------------------------------------
[S, lbls] = getpetparc(S, f_parc, type, tag_pet);

cleanup(F_cleanup);
end

%==========================================================================
function [S, lbls] = getpetparc(S, f_parc, type, tag_pet)

fprintf('\n.Extracting %sPET parcels..\n', tag_pet);

assert(isequal(type, 'surface'));

[p_lh, lbls_lh] = hb_gii2parc(S.pet.data.lh, f_parc.lh);

[p_rh, lbls_rh] = hb_gii2parc(S.pet.data.rh, f_parc.rh);

lbls = [
    lbls_lh(:)
    lbls_rh(:)
    ];

S.pet.data.parcels = [
    p_lh
    p_rh];

S.pet.data.format_parcels = 'number-of-parcels x 1';

S.pet.data.format_parcels_info = 'fist half is lh and then rh';
end

%==========================================================================
function [S, F_cleanup] = getpetsurf(f_petfs, FS, tag_pet, SaveGifti, F_cleanup)

fprintf('\n.Extracting %sPET surface-based..\n', tag_pet);

f_gii = getfgii(f_petfs, FS.surfspace);

hb_vol2surf( ...
    f_petfs, ...
    {'lh','rh'}, ...
    FS.fsopts, ...
    'OutputSurfaceName',f_gii, ...
    'SurfaceSpace', FS.surfspace);

[maplh, maprh] = loadgii(f_gii);

Nlh = length(maplh);

Nrh = length(maprh);

[~, h_petfs] = hb_nii_load(f_petfs);

S = getstruct(h_petfs, 'surface');

S.surface.Nvtx_lh = Nlh;

S.surface.Nvtx_rh = Nrh;

S.pet.data.lh = maplh;

S.pet.data.rh = maprh;

if SaveGifti

    S.f_gii = f_gii;
    
    S.f_gii_existed = false;

else
    
    F_cleanup = appendcleanup(F_cleanup, f_gii.lh);
    
    F_cleanup = appendcleanup(F_cleanup, f_gii.rh);
end
end

%==========================================================================
function f_gii = getfgii(f_petfs, surfspace)

d = strrep(f_petfs, '.gz', '');

[p,n,e] = fileparts(d);

assert(isequal(e, '.nii'));

ngii = [n,'.',surfspace,'.gii'];

f_gii = struct;

f_gii.lh = fullfile(p, ['lh.', ngii]);

f_gii.rh = fullfile(p, ['rh.', ngii]);
end

%==========================================================================
function F_cleanup = reslicetomatchfs(F,F_cleanup, tag_pet)

f_fsrib = F.fsrib;

f_fst1 = F.fst1;

f_pet = F.pet;

f_pett1 = F.pett1;

d_fsl = F.fsl;

f_petfs = F.petfs;

f_pett1brainfs = F.pett1brainfs;

f_pett1brain = F.pett1brain;

f_pet2fs = F.pet2fs;

chk1 = logical(exist(f_pett1brainfs, 'file'));

chk2 = logical(exist(f_petfs, 'file'));

if chk1 && chk2
    return;
end

[f_pet, f_tmp] = chkpet(f_pet);

assert(hb_nii_verify_space_match(f_fsrib, f_fst1), ...
    'space match issue in FS space'); % verify match "within" FS space 

assert(hb_nii_verify_space_match(f_pet, f_pett1), ...
    'space match issue in PET space');  % verify match "within" TP space

% skullstrip PET T1--------------------------------------------------------
hb_skullstrip(f_pett1, f_pett1brain, 'Method', 'FSL', 'PathFSL', d_fsl);

% regiter PET to FS & reslice---------------------------------------------- 
fprintf('\n.Registering %sPET to FS ribbon/parcellation..\n', tag_pet);

biofinder_pet2t1( ...
    f_pet, ...
    f_pett1brain, ...
    f_fst1, ...
    f_petfs, ...
    f_pett1brainfs, ...
    f_pet2fs, ...
    'PathFSL', d_fsl);

% some checks
assert(hb_nii_verify_space_match(f_pett1brainfs, f_fsrib));

assert(hb_nii_verify_space_match(f_petfs, f_fsrib));

% cleanup
if ~isempty(f_tmp)

    delete(f_tmp);
end

F_cleanup = appendcleanup(F_cleanup, f_pett1brainfs);

F_cleanup = appendcleanup(F_cleanup, f_petfs);

if endsWith(f_petfs, '.nii')

    d = [f_petfs, '.gz'];
    
    if exist(d, 'file')
    
        F_cleanup = appendcleanup(F_cleanup, d);
    end
end

if endsWith(f_petfs, '.nii.gz')

    d = strrep(f_petfs, '.gz', '');
    
    if exist(d, 'file')
    
        F_cleanup = appendcleanup(F_cleanup, d);
    end
end
end

%==========================================================================
function [f_pet, f_tmp] = chkpet(f)

try
    % line 268 in spm_select.m that throws an error:

    nifti(f);
    
    f_pet = f;
    
    f_tmp = [];
    
    fprintf('.\nPET file ok: %s', f);

catch
    
    %-there is an issue with reading the PET file (f_pet)
    %-related to data format.
    %-so we just load & rewrite it.
    
    [v, h] = hb_nii_load(f);
    
    f_tmp = fullfile(fileparts(f), sprintf('%s.nii', get_randtag));
    
    fprintf('.\nLoading & re-writing PET file: %s', f_tmp);
    
    h.fname = f_tmp;
    
    spm_write_vol(h,v);
    
    f_pet = f_tmp;
end
end

%==========================================================================
function S = getstruct(h_pet, space)

S = struct;

S.pet.fname = h_pet.fname;

S.pet.header.dim = h_pet.dim;

S.pet.header.mat = h_pet.mat;

assert(isequal(space, 'surface'));

S.pet.data.lh = [];

S.pet.data.rh = [];

S.pet.data.descrip = {
    'pet.fname was:'
    '1) suvrat_vox_mean_time_average_1.nii flirt-ed to FS ribbon'
    '2) projected to surface & vectorized'
    };

S.surface.Nvtx_lh = [];

S.surface.Nvtx_rh = [];
end

%==========================================================================
function t = get_randtag

t = sprintf('tmp%d',round(rand*1e12));
end

%==========================================================================
function [maplh, maprh] = loadgii(f_gii)

d = gifti(f_gii.lh);

maplh = d.cdata;

d = gifti(f_gii.rh);

maprh = d.cdata;

assert(size(maplh,1)>size(maplh,2));

assert(size(maplh,2)==1);

assert(size(maprh,1)>size(maprh,2));

assert(size(maprh,2)==1);
end

%==========================================================================
function F = appendcleanup(F, f)

if isempty(F)

    F{1} = f;

else

    F{length(F)+1} = f;
end
end

%==========================================================================
function cleanup(F)

if isempty(F)

    return;
end

for k=1:length(F)

    f = F{k};
    
    delete(f);
    
    if endsWith(f, '.nii.gz')
        % if a zip file is to be deleted then that means no need for the
        % unzipped version, so also delete the unzipped version of it has
        % been left behind.

        f = strrep(f, '.nii.gz', '.nii');
        
        if exist(f, 'file')
        
            delete(f);
        end
    end
end
end
