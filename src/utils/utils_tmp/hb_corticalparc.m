function param = hb_corticalparc(param,varargin)
%     
% dependencies:
%   .SPM12
%   .github/aitchbi/matlab-utils
%
% h behjat

p = inputParser;

addParameter(p, 'JustGetSurfaceParcellation', false);

parse(p,varargin{:});

optsmain = p.Results;

JustGetSurfaceParcellation = optsmain.JustGetSurfaceParcellation;

fs_main  = fullfile(param.dir_subjs, param.ID);

fs_surf  = fullfile(fs_main, 'surf');

fs_HB    = fullfile(fs_main, 'HB');

f_ribbon = fullfile(fs_main, 'mri', 'ribbon.nii');

tag_atlas = lower(param.WhichAtlas);

assert(contains(tag_atlas, 'schaefer'));

n_atlasdir = 'schaefer';

f_rois = fullfile(fs_HB, n_atlasdir, [tag_atlas, '.nii']);

[~, ~] = mkdir(fileparts(f_rois));

param.f_refrib = build_masks(f_rois);

param.tag_atlas = tag_atlas;

param.f_rois    = f_rois;

if param.JustGetRoisName

    d = struct;

    d.WhichParcellation = param.WhichAtlas;

    param.f_surfrois = hb_aparcfsavg2subj(f_rois, d, ...
        'JustGetSurfaceParcellation', true,...
        'JustGetSurfaceParcellationNames', true);
end

%-prepare inputs.
%--------------------------------------------------------------------------
opts = struct;

opts.ID = param.ID;

opts.dirs.freesurfer = param.dir_freesurfer;

opts.dirs.fsavg_hb = param.dir_fsaverage_hb;

opts.dirs.subjs = param.dir_subjs;

opts.WhichParcellation = param.WhichAtlas;

opts.dir_hbfssh = param.dir_hbfssh;

opts.files.sh_aparcfsavg2subj = fullfile(param.dir_hbfssh, 'hb_aparcfsavg2subj.sh');

opts.files.sh_annot2seg = fullfile(param.dir_hbfssh, 'hb_annot2seg.sh');

opts.files.ribbonT1w = f_ribbon;

opts.files.srfs.lh = {
    fullfile(fs_surf,'lh.pial.surf.gii')
    fullfile(fs_surf,'lh.white.surf.gii')
    };

opts.files.srfs.rh = {
    fullfile(fs_surf,'rh.pial.surf.gii')
    fullfile(fs_surf,'rh.white.surf.gii')
    };

if param.parallel_nowhere
    opts.RunPar = false;
else
    if isfield(opts, 'parallel_subjs')
        opts.RunPar = not(param.parallel_subjs);
    else
        opts.RunPar = true;
    end
end

if isfield(param, 'resolution')
    % not needed if not reslicing volumetric parc
    opts.resTag = ['.res', param.resolution];
end

if isfield(param, 'refnii')
    % not needed if not reslicing volumetric parc
    opts.files.refnii = param.refnii;
end

%-get gifti files if missing.
%--------------------------------------------------------------------------
sfiles = [
    opts.files.srfs.lh
    opts.files.srfs.rh
    ];

for k=1:length(sfiles)
    
    f_gii = sfiles{k};
    
    if not(exist(f_gii,'file'))
        
        f_orig = strrep(f_gii, '.surf.gii', '');
        
        assert(exist(f_orig, 'file'));
        
        cmd = sprintf('%s -d %s -r %s -i %s -o %s',...
            fullfile(param.dir_hbfssh, 'hb_fs_mris_convert.sh'),...
            param.dir_subjs,...
            param.dir_freesurfer,...
            f_orig,... % xx.pial/white
            f_gii...   % xx.pial/white.surf.gii
            );
        
        hb_runcmd(cmd,'Error converting surface file.');
    
    end
end

%-get parcellation.
%--------------------------------------------------------------------------
opts.DoPruning = false;

opts.OverWriteExistingRois = param.OverWriteExistingRois;

if JustGetSurfaceParcellation

    AlsoGetRefRibbon = true;

else

    AlsoGetRefRibbon = [];
end

param.f_surfrois = hb_aparcfsavg2subj( ...
    f_rois, ...
    opts, ...
    'JustGetSurfaceParcellation', JustGetSurfaceParcellation, ...
    'AlsoGetRefRibbon', AlsoGetRefRibbon,...
    'DeleteCopiedFsaverageHB', false); % reuired in parallel runs

flh = param.f_surfrois.lh;

frh = param.f_surfrois.rh;

if exist(flh, 'file')
    f_parcsize_lh = strrep(flh, '.annot', '.parcsize.mat');
    
    if ~exist(f_parcsize_lh, 'file')
    
        N = hb_annot_get_parcsize(flh);
        
        save(f_parcsize_lh, 'N');
    end
end

if exist(frh, 'file')
    
    f_parcsize_rh = strrep(frh, '.annot', '.parcsize.mat');
    
    if ~exist(f_parcsize_rh, 'file')
    
        N = hb_annot_get_parcsize(frh);
        
        save(f_parcsize_rh, 'N');
    end
end

if exist(flh, 'file') && exist(frh, 'file')
    
    d = strrep(flh, 'lh.', '');
    
    f_parcsize_lhrh = strrep(d, '.annot', '.parcsize.mat');
    
    if ~exist(f_parcsize_lhrh, 'file')
    
        N1 = hb_annot_get_parcsize(flh);
        
        N2 = hb_annot_get_parcsize(frh);
        
        N = [N1; N2];
        
        save(f_parcsize_lhrh, 'N');
    end
end
end

%==========================================================================
function hb_runcmd(cmd,errmsg)

[sts,log] = system(cmd);

if sts==0
    return;
end

sprintf('*** system run log: \n\n');

log %#ok<NOPRT>

error(errmsg)

end

%==========================================================================
function [f_rib, f_ctx, f_sub] = build_masks(f_rois)

[p,n] = fileparts(f_rois);

n = strrep(n, '.nii', ''); % in case .gz file

f_rib = fullfile(p,[n,'_refrib.nii']);

f_ctx = [];

f_sub = [];
end
