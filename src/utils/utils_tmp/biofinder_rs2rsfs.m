function S = biofinder_rs2rsfs(space, f_rs, f_ab, f_xfm, f_wrp, FS, d_ANTs, varargin)
% BIOFINDER_RS2RSFS take BF resting-state (RS) data to FreeSurfer (FS)
% space and extract time-courses for ribbon or surface.
%
% pipeline:
%   (a) apply f_xfm to f_rs
%   (b) apply f_wrp to (a)
%   (c) reslice (b) to match f_ab
%   (d) register and reslice (c) to f_fs.rib to get f_out
%
% inputs:
%  space: 'volumetric' or 'surface'
%
%   f_rs: rs_processed_censored_32bit.nii
%
%   f_ab: anatomical_brain/<reference-anatomical-brain>.nii
%
%  f_xfm: functional_to_anat_linear_xfm_converted/f2a.txt
%
%  f_wrp: funwarps/<*_ID_scandate>/transform0Warp.nii
%
%     FS: structure with fields "f_ribbon"; and 'fsopts' if space=='surface'
%
%  f_out: output file; rs file match to fs-space parcellation.
%
% output:
%   S: structure with firelds:
%
% dependencies:
%   .SPM12 toolbox
%   .ANTs
%   .github/aitchbi/matlab-utils
%
% h behjat

d = inputParser;

addParameter(d, 'DirTmpFast', []);

parse(d,varargin{:});

opts = d.Results;

f_ants = fullfile(d_ANTs, 'antsApplyTransforms');

h_rs = spm_vol(f_rs);

N_t = length(h_rs);

dim_rs = h_rs(1).dim;

mat_rs = h_rs(1).mat;

dt_rs  = h_rs(1).dt;

tag = get_randtag;

if isempty(opts.DirTmpFast)

    d = strrep(f_rs, '.gz', '');
    
    f_s1 = strrep(d, '.nii', sprintf('_%s_step1.nii',tag));
    
    f_s2 = strrep(d, '.nii', sprintf('_%s_step2.nii',tag));
    
    f_s3 = strrep(d, '.nii', sprintf('_%s_step3.nii',tag));
else
    
    tag2 = get_randtag;
    
    d = sprintf('biofinder_rs2rsfsrib_%s', tag2);
    
    d = fullfile(opts.DirTmpFast, d);
    
    mkdir(d);
    
    f_s1 = fullfile(d, sprintf('step1_%s.nii', tag));
    
    f_s2 = fullfile(d, sprintf('step2_%s.nii', tag));
    
    f_s3 = fullfile(d, sprintf('step3_%s.nii', tag));
end

[p,n,e] = fileparts(f_s3);

assert(isequal(e,'.nii'));

f_gii = struct;

f_gii.lh = fullfile(p, ['lh.',n,'.gii']);

f_gii.rh = fullfile(p, ['rh.',n,'.gii']);

h0 = struct;

h0.fname = f_s1;

h0.dim = dim_rs;

h0.mat = mat_rs;

h0.dt = dt_rs;

h0 = spm_create_vol(h0);

S = struct; % output structure

S.rsfmri.fname = f_rs;

S.rsfmri.header.dim  = dim_rs;

S.rsfmri.header.mat  = mat_rs;

S.rsfmri.data.lh = [];

S.rsfmri.data.rh = [];

S.rsfmri.data.ctx = [];

S.rsfmri.data.subctx = [];

assert(isequal(space, 'surface'));

S.rsfmri.data.format = 'number-of-vertices x number-of-frames';

S.rsfmri.data.descrip = {
    'rsfmri.fname was:'
    '1) suscep corrected & resliced to anatomical (via ANTs)'
    '2) projected to surface (via hb_vol2surf)'
    '3) rsfmri vertex values in lh/rh urface extracted'
    '4) each vector (frame/time-point) saved as a column in matrix.'
    };
S.surface.space = FS.surfspace;

S.surface.N_vertices_lh = [];

S.surface.N_vertices_rh = [];

RegisterThenReslice = false;

for iT=1:N_t
    
    assert(isequal(h_rs(iT).dim, dim_rs));
    
    assert(isequal(h_rs(iT).mat, mat_rs));
    
    assert(isequal(h_rs(iT).dt, dt_rs));
    
    %-extract single frame.
    %----------------------------------------------------------------------
    v = spm_read_vols(h_rs(iT));
    
    spm_write_vol(h0,v);
    
    %-suscep correct & reslice to anatomical.
    %----------------------------------------------------------------------
    cmd = sprintf('%s -i %s -r %s -o %s -t %s -t %s',...
        f_ants,...
        f_s1,...  % -i
        f_ab,...  % -r
        f_s2,...  % -o
        f_wrp,... % -t nonlinear suscep corr
        f_xfm...  % -t rigid to anat
        );
    
    runcmd(cmd,iT);
    
    if iT==1
        verifreg(f_s2,f_ab, 't1');
    end

    %-reslice to match FS ribbon.
    %----------------------------------------------------------------------
    hb_nii_reslice(f_s2, FS.f_ribbon, 1, f_s3, true, [], RegisterThenReslice);

    if iT==1
        
        sts = verifreg(f_s3,FS.f_ribbon, 'ribbon', false);
        
        if sts==0
        
            fprintf('\n.Trying again. First register, then reslice.')
            
            delete(f_s3);
            
            RegisterThenReslice = true;
            
            hb_nii_reslice(f_s2, FS.f_ribbon, 1, f_s3, true, [], RegisterThenReslice);
            
            verifreg(f_s3,FS.f_ribbon, 'ribbon', true);
            
            fprintf('\n.Register then reslice worked!');
            
            fprintf('\n.Note: upto 10s/frame longer process time.');
        end
    end

    %-project to surface, extract values & store.
    %----------------------------------------------------------------------
    hb_vol2surf( ...
        f_s3, ...
        {'lh','rh'}, ...
        FS.fsopts, ...
        'OutputSurfaceName',f_gii, ...
        'SurfaceSpace', FS.surfspace);

    assert(exist(f_gii.lh, 'file'), 'f_gii.lh missing');

    assert(exist(f_gii.rh, 'file'), 'f_gii.rh missing');

    f_gii

    [maplh, maprh] = loadgii(f_gii, iT);

    if iT==1

        Nlh = length(maplh);
        
        Nrh = length(maprh);
        
        S.surface.N_vertices_lh = Nlh;
        
        S.surface.N_vertices_rh = Nrh;
        
        S.rsfmri.data.lh  = zeros(Nlh, N_t);
        
        S.rsfmri.data.rh  = zeros(Nrh, N_t);
    end

    S.rsfmri.data.lh(:,iT) = maplh;
    
    S.rsfmri.data.rh(:,iT) = maprh;

    showprgs(iT,N_t);
end

delete(f_s1);

delete(f_s2);

delete(f_s3);

delete(f_gii.lh);

delete(f_gii.rh);
end

%==========================================================================
function t = get_randtag
t = sprintf('tmp%d',round(rand*1e16));
end

%==========================================================================
function runcmd(cmd,iT)
[sts, log] = system(cmd);
if sts==0
    if iT==1
        fprintf('\n..ANTs successful on first frame.\n');
        log
    end
else
    sprintf('*** ANTS''s log ***');
    log %#ok<*NOPRT>
    error('ANTS error.');
end
end

%==========================================================================
function showprgs(n,N)
l = numel(num2str(N));
if n==1
    fprintf('\n..Processing rs-fMRI.. ');
else
    fprintf(repmat('\b',1,2*l+1),n);
end
eval(['fprintf(''%-',num2str(l),'d/%-',num2str(l),'d'',n,N)'])
end

%==========================================================================
function [maplh, maprh] = loadgii(f_gii, iT)
d = gifti(f_gii.lh);
maplh = d.cdata;
d = gifti(f_gii.rh);
maprh = d.cdata;
if iT==1
    assert(size(maplh,1)>size(maplh,2));
    assert(size(maplh,2)==1);
    assert(size(maprh,1)>size(maprh,2));
    assert(size(maprh,2)==1);
end
end

%==========================================================================
function sts = verifreg(f_rs,f_ab,type,ThrowError)
th = 0.05; % percenatge of mismatch, fraction of 1  
[v_rs,h_rs] = hb_nii_load(f_rs);
[v_ab,h_ab] = hb_nii_load(f_ab);
hb_nii_verify_space_match(h_rs, h_ab);
v_rs(isnan(v_rs)) = 0;
v_ab(isnan(v_ab)) = 0;
v1 = imfill(logical(v_rs), 'holes');
v2 = imfill(logical(v_ab), 'holes');
v3 = and(v1,v2);
n1 = nnz(v1);
n2 = nnz(v2);
n3 = nnz(v3);
ndiff1 = n1-n3;
ndiff2 = n2-n3;
assert(ndiff1>=0, 'fishy');
assert(ndiff2>=0, 'fishy');
p1d = ndiff1/n1;
p2d = ndiff2/n2;
t = 'Percentage of';
disp(' ');
fprintf('----------registeration check.');
fprintf('\n.Registeration Verification Report:');
fprintf('\n..RS file: %s', f_rs);
fprintf('\n..Anatomical file: %s', f_ab);
switch type
    case 't1'
        fprintf('\n..%s RS voxels outside anatomical: %0.1f%% (P1)',t,p1d*100);
        fprintf('\n..%s anatomical voxels outside RS: %0.1f%% (P2)',t,p2d*100);
        fprintf('\n..Pass criteria: P1, P2 or both should be less than %d%%',th*100);
        if or(p1d<=th, p2d<=th)
            fprintf('\n..Registeration between RS & anatomical image is OK.');
        else
            error('Registeration between RS & anatomical image is fishy.');
        end
    case 'ribbon'
        fprintf('\n..%s Ribbon voxels without RS value: %0.1f%% (P)',t,p2d*100);
        fprintf('\n..Pass criteria: P should be less than %d%%',th*100);
        if p2d<=th
            fprintf('\n..Registeration between RS & ribbon is OK.');
            sts = 1;
        else
            sts = 0;
            if ThrowError
                error('Registeration between RS & ribbon is fishy.');
            else
                fprintf('\n..Registeration between RS & ribbon is fishy.');
            end
        end
end
fprintf('\n----------registeration check.');
disp(' ');
end
