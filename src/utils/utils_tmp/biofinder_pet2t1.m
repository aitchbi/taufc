function [f_pett1b, f_t1refb] = biofinder_pet2t1(f_pet, f_pett1, f_t1ref, f_petnew, f_t1new, f_affine, varargin)
% BIOFINDER_PET2T1 registers tau/amyloid PET to a t1 target image via
% registering the t1 that is already matched to the tau image to the target
% t1.
%
% inputs:
%   f_pet: pet to be registred to t1 ref.
%   f_pett1: t1 in register with f_pet. 
%   f_t1ref: t1 to which pet is to be registered to.
%
% outputs:
%   f_petnew: pet registered to t1 ref. 
%   f_t1new: t1 registered to t1 ref.
%   f_affine: the affine registeration.  
%
% dependencies:
%  .SPM
%  .FSL 
%  .github/aitchbi/matlab-utils
%
% h behjat

d = inputParser;

addParameter(d, 'PathFSL', []);

addParameter(d, 'SkullStripPetT1', false); 

addParameter(d, 'SkullStripRefT1', false); 

parse(d,varargin{:});

opts = d.Results;

chk1 = exist(f_t1new, 'file');

chk2 = exist(f_petnew, 'file');

chk3 = exist(f_affine, 'file') || isempty(f_affine);

if all([chk1, chk2, chk3])

    return;
end

F_cleanup = {};

ReEstimateAffine = false;

if opts.SkullStripPetT1
    
    f_pett1b = getbfname(f_pett1);
    
    hb_skullstrip(f_pett1, f_pett1b, 'Method', 'FSL', 'PathFSL', opts.PathFSL);
    
    ReEstimateAffine = true;

else
    
    f_pett1b = f_pett1;
end

if opts.SkullStripRefT1
    
    f_t1refb = getbfname(f_t1ref);
    
    hb_skullstrip(f_t1ref, f_t1refb, 'Method', 'FSL', 'PathFSL', opts.PathFSL);
    
    ReEstimateAffine = true;

else
    
    f_t1refb = f_t1ref;
end

f_ref = f_t1refb;

f_flirt = hb_fsl_get_func(opts.PathFSL, 'flirt');

if isempty(f_affine)

    f_affine = strrep(f_pett1b, '.nii', '___tmp___affine.mat');
    
    F_cleanup = [F_cleanup f_affine];
end

if ~exist(f_affine, 'file') || ReEstimateAffine
    
    % estimate registeration to get registration matrix
    
    f_in  = f_pett1b;
    
    cmd = sprintf('%s -in %s -ref %s -omat %s',...
        f_flirt,...
        f_in,...
        f_ref,...
        f_affine);
    
    runcmd(cmd, 'HB: Error in FSL flirt.');
end

if isempty(f_t1new)
    
    f_t1new = strrep(f_pett1b, '.nii', '___tmp___movedt1.nii');
    
    F_cleanup = [F_cleanup f_t1new];
end

% apply registration matrix to t1

f_in  = f_pett1b;

f_out = f_t1new;

cmd = sprintf('%s -in %s -ref %s -applyxfm -init %s -out %s',...
    f_flirt,...
    f_in,...
    f_ref,...
    f_affine,...
    f_out);

runcmd(cmd, 'HB: Error in FSL flirt.');

[d, msg] = hb_nii_verify_overlap(f_out,f_ref,95,'either','MinimumOverlap',90);

switch d
    
    case true
    
        % registration OK
    
    case false
    
        fprintf('\n..Registration/overlap problem bw files f1 & f2: %s', msg);
        
        fprintf('\n...f1 (f_out): %s', f_out);
        
        fprintf('\n...f2 (f_ref): %s\n', f_ref);
        
        error('Registration problem.');
end

% apply registration matrix to pet

f_in  = f_pet;

f_out = f_petnew;

cmd = sprintf('%s -in %s -ref %s -applyxfm -init %s -out %s',...
    f_flirt,...
    f_in,...
    f_ref,...
    f_affine,...
    f_out);

runcmd(cmd, 'HB: Error in FSL flirt.');

% cleanup
if ~isempty(F_cleanup)

    for k=1:length(F_cleanup)
    
        delete(F_cleanup{k});
    end
end
end

%==========================================================================
function runcmd(cmd, msg)

[sts, log] = system(cmd);

if sts~=0

    sprintf('*** FSL''s log ***\n\n');
    
    log %#ok<*NOPRT>
    
    error(msg);
end
end

%==========================================================================
function f = getbfname(f)

f = strrep(f, '.nii', '.brain.nii')
end

