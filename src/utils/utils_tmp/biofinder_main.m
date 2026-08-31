function outs = biofinder_main(DoWhat, sess, I, WhichAtlas, varargin)

d = inputParser;

addParameter(d,'Verbose', true);

parse(d,varargin{:});

opts = d.Results;

[BF2, dirs, ~] = biofinder_setup('DoAddpaths', false, 'GetFilesBiofinder', true);

opts.DirMeta = dirs.meta;

[DoWhat, WhichSess, IDs] = verifyinputs(DoWhat, sess, I, WhichAtlas, opts);

if ischar(IDs)

    if strcmp(IDs,'all-unique-subjects')

        IDs = unique(BF2.freesurfer(:,1));

    elseif contains(IDs,'IDs_rsfs_1743')

        d = fullfile(dirs.meta,[IDs,'.mat']);

        d = load(d);

        IDs = d.(IDs);

    else
        error('unkown IDs format');
    end
else
    assert(isnumeric(IDs));
end

N_IDs = length(IDs);

IDs_problem = [];

WhichRes = [];

parallel_nowhere = true;

parallel_subjs = false;

outs = struct;

t1 = tic;

for iID=1:N_IDs

    ID = IDs(iID);

    t2 = tic;

    runmainpvt(...
        DoWhat,...
        ID,...
        WhichSess,...
        WhichAtlas,...
        WhichRes,...
        BF2,...
        dirs,...
        parallel_nowhere,...
        parallel_subjs,...
        {'full-session'},...
        false,...
        opts);

    fprintf('\n..Subject done. [%d, %d/%d]', ID, iID, N_IDs);

    tt2 = toc(t2);

    if tt2<180
    
        fprintf('\n..Subject time: %d seconds.\n', round(tt2));
    
    else
    
        fprintf('\n..Subject time: %d minutes.\n', round(tt2/60));
    end
end

fprintf('\n\n..Number of subjects with problem: %d',length(IDs_problem));

disp(' ');
fprintf('\n..Script done.');
fprintf('\n..Script time: %d minutes.\n', round(toc(t1)/60));
end

%==========================================================================
function outs = runmainpvt(DoWhat, ID, WhichSess, WhichAtlas, WhichRes, BF2, dirs, parallel_nowhere, parallel_subjs, WhichFCs, JustCheckExistRequiredFiles, opts)

outs = struct;

if contains(DoWhat, 'TauPet')

    WhichPet = 'Tau';

elseif contains(DoWhat, 'AmyPet')

    WhichPet = 'Amyloid';

else

    WhichPet = [];
end

[sess_fs_v1, scandate_fs] = biofinder_getMID(ID, BF2, WhichSess, 'FS');

if isempty(sess_fs_v1)

    fprintf('\n\n..No FS session %d in BF2. [ID: %d] ---subject skipped.\n', WhichSess, ID);
    
    return;
end

switch DoWhat
    
    case 'BuildFC_SurfaceSUBJ'
        
        chk = biofinder_checkExistSessDate(ID,BF2,scandate_fs,'RS'); 

        if chk~=1
    
            fprintf('No RS session matching FS session; subject skipped.');
            
            return;
        end
end

sees_fs_v2 = sprintf('_subject_id_%s',sess_fs_v1);

fprintf('\n..Working on: %s \n', sess_fs_v1);

d_fs_subjs_orig = fullfile(dirs.bfdata, 'fs', 'x', sees_fs_v2, 'autorecon1'); % orig files in non-writable directory

if isempty(dirs.RootDirectoryToDuplicateFilesIntoAndWork)

    d_fs_subjs = d_fs_subjs_orig;
    
    d_fs = fullfile(d_fs_subjs, sess_fs_v1);
    
    files_to_cleanup = [];
    
    d_fs_orig = d_fs;

else
    
    d = dirs.RootDirectoryToDuplicateFilesIntoAndWork;

    d_fs_subjs = fullfile(d, 'fs', 'x');
    
    d_fs = fullfile(d_fs_subjs, sess_fs_v1);
    
    [~, ~] = mkdir(d_fs);
    
    d_fs_orig = fullfile(d_fs_subjs_orig, sess_fs_v1);
end

switch DoWhat
    
    case {
            'JustCheckExistRequiredFiles'
            'BuildParcels_surface'
            'BuildFC_SurfaceSUBJ'
            'JustCheckExistRequiredFiles_SurfaceSUBJ'
            }

        if not(isempty(dirs.RootDirectoryToDuplicateFilesIntoAndWork))

            [files_to_cleanup, sts] = duplicatefiles(d_fs, d_fs_orig, 'MRI');
            
            if sts == 0
            
                fprintf('\n.FS files missing for: %s', sess_fs_v1);
                
                outs.f_FC = [];
                
                cleanup(files_to_cleanup);
                
                return;
            end
        end

        files_to_cleanup_after_all_atlases = files_to_cleanup;

        files_to_cleanup = [];

        f_fst1_ref = getlowresref(WhichRes, d_fs_subjs, sess_fs_v1, dirs);

       JustFetchMergeExistingFC = false;
       
    case {
            'ParcellateTauPet_SurfaceSUBJ'
            'ParcellateAmyPet_SurfaceSUBJ'
            }

        switch WhichPet

            case 'Tau'

                d_tp_main = fullfile(dirs.pet, 'tnic_sr_mr');

                [sess_tp, ~] = biofinder_getPetSessMatchingFsSess(ID, BF2, scandate_fs, 'tau');

                d = fullfile(d_tp_main, sess_tp);

                if ~exist(d, 'dir')
                
                    fprintf('\n.Fishy: %s-PET session missing despite being in BF2.mat: %s\n', WhichPet, d);
                    
                    return;
                end

                if isempty(sess_tp)
                    
                    fprintf('\n.sess_tp is empty; %s-PET parcellation skipped.', WhichPet);
                    
                    return;
                end

                d_tp = fullfile(d_tp_main, sess_tp);
                
                d_tpt1 = fullfile(dirs.pet, 'tau_t1', sess_tp);

                d_tpHB = fullfile(d_tp, 'HB');
                
                d_tpt1HB = fullfile(d_tpt1, 'HB');

                n_tp = 'suvrat_vox_mean_time_average_1';
                
                n_tpt1 = 't1_reo_resample';

                f_tp = fullfile(d_tp, [n_tp, '.nii.gz']);
                
                f_tpt1 = fullfile(d_tpt1, [n_tpt1, '.nii.gz']);

                assert(logical(exist(f_tp, 'file')));

                assert(logical(exist(f_tpt1, 'file')));

                [~, ~] = mkdir(d_tpHB);

                [~, ~] = mkdir(d_tpt1HB);

            case 'Amyloid'

                d_ap_main = fullfile(dirs.pet, 'fnc_sr_mr');

                [sess_ap, ~] = biofinder_getPetSessMatchingFsSess(ID, BF2, scandate_fs, 'amy');

                d = fullfile(d_ap_main, sess_ap);

                if ~exist(d, 'dir')
                
                    fprintf('\n.Fishy: %s-PET session missing despite being in BF2.mat: %s\n', WhichPet, d);
                    
                    return;
                end

                if isempty(sess_ap)
                    
                    fprintf('\n.sess_ap is empty; %s-PET parcellation skipped.', WhichPet);

                    return;
                end

                d_ap   = fullfile(d_ap_main, sess_ap);
                
                d_apt1 = fullfile(dirs.pet, 'amyloid_t1', sess_ap);

                d_apHB   = fullfile(d_ap, 'HB');
                
                d_apt1HB = fullfile(d_apt1, 'HB');

                n_apt1 = 't1_reo_resample';
                
                f_apt1 = fullfile(d_apt1, [n_apt1, '.nii.gz']);
                
                assert(logical(exist(f_apt1, 'file')));

                n_ap_options = {
                    'suvrat_vox_mean_time_average_1' 
                    'suvrat_vox_mean_time_average_2' 
                    'suvrat_vox_mean_time_average_4' 
                    };

                for k=1:length(n_ap_options)

                    n_ap = n_ap_options{k};
                    
                    f_ap = fullfile(d_ap, [n_ap, '.nii.gz']);
                    
                    if exist(f_ap, 'file')
                    
                        amyfound = true;
                        
                        break;
                    else
                        
                        amyfound = false;
                    end
                end
                
                assert(amyfound);

                [~, ~] = mkdir(d_apHB);
                
                [~, ~] = mkdir(d_apt1HB);
        end

        files_to_cleanup = [];

        f_fst1_ref = [];

        JustFetchMergeExistingFC = false;

        switch DoWhat

            case {
                    'ParcellateTauPet_SurfaceSUBJ' 
                    'ParcellateAmyPet_SurfaceSUBJ' 
                    }

                [d, sts] = duplicatefiles(d_fs, d_fs_orig, 'MRI');
                
                if sts == 0
                
                    fprintf('\n.FS files missing for: %s', sess_fs_v1);
                    
                    outs.f_FC = [];
                    
                    cleanup(d);
                    
                    return;
                else
                    
                    files_to_cleanup_after_all_atlases = d;
                end
        end
end

schaeferyeo7 = {
    'schaefer100yeo7'
    'schaefer200yeo7'
    'schaefer300yeo7'
    'schaefer400yeo7'
    'schaefer500yeo7'
    'schaefer600yeo7'
    'schaefer700yeo7'
    'schaefer800yeo7'
    'schaefer900yeo7'
    'schaefer1000yeo7'
    };

N_atlas = length(WhichAtlas);

for iAtlas = 1:N_atlas

    ThisAtlas = WhichAtlas{iAtlas};

    atlaslower = lower(ThisAtlas);

    assert(ismember(atlaslower, schaeferyeo7));
    
    %-Get coritical parcellaton.
    %----------------------------------------------------------------------
    param = struct;
    
    param.ID               = sess_fs_v1; 
    
    param.WhichAtlas       = ThisAtlas;
    
    param.parallel_nowhere = parallel_nowhere;
    
    param.parallel_subjs   = parallel_subjs;
    
    param.dir_freesurfer   = dirs.freesurfer;
    
    param.dir_fsaverage_hb = dirs.fsaverage_hb;
    
    param.dir_subjs        = d_fs_subjs;
    
    param.resolution       = WhichRes;   
    
    param.refnii           = f_fst1_ref; 
    
    param.dir_hbfssh       = dirs.hbfssh;
    
    if JustCheckExistRequiredFiles || JustFetchMergeExistingFC
    
        f_fsrib = [];
    else
        
        param.OverWriteExistingRois = false;

        switch DoWhat

            case 'BuildParcels_surface'

                param.JustGetRoisName = false;

                JGSP = true;

                param = hb_corticalparc(param, 'JustGetSurfaceParcellation', JGSP);

                fprintf('\n..Subject %d, %s done.\n', ID, ThisAtlas);

                if strcmp(param.WhichAtlas, 'braak')

                    f_fsrib = param.f_refrib;
                else

                    f_fsrib = strrep(param.f_rois, '.nii', '_refrib.nii');
                end
                
            otherwise

                param.JustGetRoisName = true;
                
                param = hb_corticalparc(param);
                
                f_fsrib = param.f_refrib;
        end
    end

    if contains(DoWhat, '_SurfaceSUBJ')

        surfspace = 'subject';
    
    else
    
        surfspace = 'n/a';
    end

    FS = struct;
    
    FS.fsopts.ID = sess_fs_v1;
    
    FS.f_ribbon  = f_fsrib;
    
    FS.surfspace             = surfspace;
    
    FS.fsopts.dir_subjs      = param.dir_subjs;
    
    FS.fsopts.sh_vol2surf    = fullfile(param.dir_hbfssh, 'hb_vol2surf.sh');
    
    FS.fsopts.dir_fsavg_hb   = param.dir_fsaverage_hb;
    
    FS.fsopts.dir_freesurfer = param.dir_freesurfer;

    switch FS.surfspace

        case 'subject'

            FS.tag_surf = 'subjsurf';
        
        case {'fsaverage', 'fsLR'}
            
            FS.tag_surf = FS.surfspace;
        
        otherwise
            
            FS.tag_surf = [];
    end

    f_fst1  = getfilefst1(d_fs, param, d_fs_orig);

    switch DoWhat

        case 'BuildFC_SurfaceSUBJ'

            for iWhichFC = 1:length(WhichFCs)

                WhichFC = WhichFCs{iWhichFC};

                %-file names-----------------------------------------------
                [~, ~, d_FC] = get_fcfile(d_fs, WhichFC, 'Subject', ThisAtlas);

                [~,~] = mkdir(d_FC);

                f_parclbls = fullfile(d_FC, [atlaslower, '.labels.mat']);

                [f_FC_surface, f_TC_surface] = get_fcfile_surf(d_fs, WhichFC, ThisAtlas, FS.tag_surf);
               
                if JustFetchMergeExistingFC

                    outs.f_FC = f_FC_surface;

                    cleanup(files_to_cleanup);

                    continue; % next atlas..
                end
               
                %-check FC exist-------------------------------------------

                opts6 = struct;

                switch DoWhat

                    case 'BuildFC_SurfaceSUBJ'

                        opts6.f_FC_surface = f_FC_surface;

                        opts6.f_TC_surface = f_TC_surface;
                end

                sts = checkexist_FC(DoWhat,ThisAtlas,opts6);
                
                if sts==1
                    continue;
                end
               
                switch DoWhat

                    case 'BuildFC_SurfaceSUBJ'

                        if not(exist('S','var'))

                            %-Prepare.
                            %----------------------------------------------
                            d_fs_subjs_orig = fullfile(dirs.bfdata, 'hd', 'data', 'rs_processed_censored_32bit');

                            n_rs = 'processed_and_censored_32bit.nii.gz';

                            if isempty(dirs.RootDirectoryToDuplicateFilesIntoAndWork)

                                f_rs = fullfile(d_fs_subjs_orig, sess_fs_v1, n_rs);

                            else
                                
                                % orig files in read-only dir; duplicate.

                                d = dirs.RootDirectoryToDuplicateFilesIntoAndWork;

                                dir_subjs_save = fullfile(d, 'hd', 'rs_processed_censored_32bit');

                                dir_rs_orig = fullfile(d_fs_subjs_orig, sess_fs_v1);

                                dir_rs_save = fullfile(dir_subjs_save, sess_fs_v1);

                                f_rs = fullfile(dir_rs_save, n_rs);

                                [~,~] = mkdir(dir_rs_save);

                                d = strrep(f_rs, dir_rs_save, dir_rs_orig);

                                if JustCheckExistRequiredFiles

                                    assert(logical(exist(d,'file')));

                                else

                                    fprintf('\n.Copying rs file.. [%s] ', f_rs);
                                    
                                    sts = copyfile(d, f_rs);
                                    
                                    assert(sts==1);
                                    
                                    files_to_cleanup = [
                                        files_to_cleanup
                                        f_rs
                                        ]; %#ok<*AGROW> 
                                end
                            end

                            %-Get rs-fMRI.
                            %----------------------------------------------
                            f_xfm = fullfile(dirs.bfdata,... 
                                'hd',...
                                'data',...
                                'functional_to_anat_linear_xfm_converted',...
                                sess_fs_v1,...
                                'f2a.txt');

                            f_wrp = fullfile(dirs.bfdata,... 
                                'hd',...
                                'data',...
                                'funwarps',...
                                sess_fs_v1,...
                                'transform0Warp.nii.gz');

                            d2 = chkexist(sess_fs_v1, f_xfm, 'f2a.txt');
                            d3 = chkexist(sess_fs_v1, f_wrp, 'transform0Warp.nii.gz');

                            % Get RS, properly preprocessed, correct space, as matrix.
                            % . preprocessing: Olof's preproc + susecpt correct.
                            % . then map to anatomical.
                            % . then reslice to match FS-space ribbon/parcelaltions.
                            % . return as matrix; no nifti save.

                            f_ab = get_file_ab(...
                                fullfile(dirs.bfdata, 'hd', 'data', 'anatomical_brain'),...
                                sess_fs_v1,...
                                ID,...
                                scandate_fs);

                            d1 = chkexist(sess_fs_v1, f_ab, 'anatomical brain');

                            if all([d1, d2, d3])
                                if JustCheckExistRequiredFiles

                                    d = 'All required files exist for: ';
                                    
                                    fprintf('\n\n..%s --- ID %d, RS session %d --- \n\n', d, ID, WhichSess);
                                    
                                    cleanup(files_to_cleanup)
                                    
                                    continue; % next atlas..
                                end
                            else

                                fprintf('\n..Subject skipped. [%s]', sess_fs_v1);
                                
                                cleanup(files_to_cleanup);
                                
                                continue; % next atlas..
                            end

                            ttt = tic;
                            S = biofinder_rs2rsfs(...
                                'surface', ...
                                f_rs,...
                                f_ab,...
                                f_xfm,...
                                f_wrp,...
                                FS,...
                                dirs.ANTs,...
                                'DirTmpFast', dirs.DirTmpFast);
                            d = round(toc(ttt)/60);
                            fprintf('\n.Surface hb_rs2rsfs time: %d minutes', d);

                            % -S contains vertex time-courses
                            % -TC is the parcel timecourses
                            % -S is useful to output when
                            % e.g. computing FC for
                            % multiple atlases in one run;
                            % massive save in time!
                        else

                            switch DoWhat

                                case 'BuildFC_SurfaceSUBJ'
                                
                                    f_rib = strrep(param.f_rois, '.nii', '_refrib.nii');

                                    assert(hb_nii_verify_space_match(f_fsrib, f_rib));
                            end
                        end
                end

                %-Build FC.
                %----------------------------------------------------------
                switch DoWhat

                    case 'BuildFC_SurfaceSUBJ'

                        [FC, ~, TC, ~, S, lbls] = biofinder_rs2fc('surface', S, param.f_surfrois, WhichFC);

                        save(f_FC_surface, 'FC');

                        fprintf('\n..Subject %d, surface FC for %s done.\n', ID, ThisAtlas);

                        save(f_TC_surface, 'TC');
                        
                        fprintf('\n..Subject %d, surface TC for %s done.\n', ID, ThisAtlas);

                        save(f_parclbls, 'lbls');
                        
                        fprintf('\n..Subject %d, labels for %s saved: %s\n', ID, ThisAtlas, f_parclbls);
                end
            end

        case {
                'ParcellateTauPet_SurfaceSUBJ'
                'ParcellateAmyPet_SurfaceSUBJ'
                }

            %-FS space-----------------------------------------------------
            tag_reg_fs   = 'reslicedToMatchFSRib';
            
            tag_brain_fs = sprintf('.brain.%s.nii.gz', tag_reg_fs);
            
            ofnames_subj = struct;

            switch WhichPet
                
                case 'Tau'
                
                    f_parclbls = fullfile(d_tpHB, [atlaslower, '.labels.mat']);

                    tag_tp_fs         = sprintf('.%s.nii', tag_reg_fs);
                    
                    f_tpfs            = fullfile(d_tpHB, [n_tp, tag_tp_fs]);
                    
                    f_tpt1brain       = fullfile(d_tpt1HB, [n_tpt1, '.brain.nii.gz']);
                    
                    f_tpt1brainfs     = fullfile(d_tpt1HB, [n_tpt1, tag_brain_fs]);
                    
                    f_tp2fs           = fullfile(d_tpt1HB, 'tp2fs.mat');
                    
                    if ~isempty(FS.tag_surf)
                    
                        f_tp_fs_parc_surf = fullfile(d_tpHB, sprintf('%s.TP_%s.mat', lower(ThisAtlas), FS.tag_surf));
                    end

                    ofnames_subj.f_petfs        = f_tpfs;
                    
                    ofnames_subj.f_pett1brain   = f_tpt1brain;
                    
                    ofnames_subj.f_pett1brainfs = f_tpt1brainfs;
                    
                    ofnames_subj.f_pet2fs       = f_tp2fs;

                case 'Amyloid'
                    
                    f_parclbls = fullfile(d_apHB, [atlaslower, '.labels.mat']);

                    tag_ap_fs         = sprintf('.%s.nii', tag_reg_fs);
                    
                    f_apfs            = fullfile(d_apHB, [n_ap, tag_ap_fs]);
                    
                    f_apt1brain       = fullfile(d_apt1HB, [n_apt1, '.brain.nii.gz']);
                    
                    f_apt1brainfs     = fullfile(d_apt1HB, [n_apt1, tag_brain_fs]);
                    
                    f_ap2fs           = fullfile(d_apt1HB, 'ap2fs.mat');
                    
                    if ~isempty(FS.tag_surf)
                    
                        f_ap_fs_parc_surf = fullfile(d_apHB, sprintf('%s.AP_%s.mat', lower(ThisAtlas), FS.tag_surf));
                    end
                    
                    ofnames_subj.f_petfs        = f_apfs;
                    
                    ofnames_subj.f_pett1brain   = f_apt1brain;
                    
                    ofnames_subj.f_pett1brainfs = f_apt1brainfs;
                    
                    ofnames_subj.f_pet2fs       = f_ap2fs;
            end

            switch DoWhat

                case {
                        'ParcellateTauPet_SurfaceSUBJ'
                        'ParcellateAmyPet_SurfaceSUBJ'
                        }

                    switch WhichPet
                
                        case 'Tau'
                        
                            d1 = f_tp;
                            
                            d2 = f_tpt1;
                            
                            d3 = f_tp_fs_parc_surf;
                            
                            OEPP = false;
                        
                        case 'Amyloid'
                        
                            d1 = f_ap;
                            
                            d2 = f_apt1;
                            
                            d3 = f_ap_fs_parc_surf;
                            
                            OEPP = false;
                    end

                    if exist(d3, 'file') && OEPP
                        
                        delete(d3);
                        
                        fprintf('\n.Deleting existing %s-PET surface parcellation: %s', WhichPet, d3);
                    end

                    if exist(d3, 'file')
                        
                        fprintf('\n.%s-PET surface parcellation exists: %s', WhichPet, d3);
                    
                    else
                    
                        f_surfparc    = struct;
                        
                        f_surfparc.lh = param.f_surfrois.lh;
                        
                        f_surfparc.rh = param.f_surfrois.rh;

                        chk1 = exist(f_surfparc.lh, 'file');
                        
                        chk2 = exist(f_surfparc.rh, 'file');

                        if chk1 && chk2

                            [S,~,lbls] = biofinder_pet2petfsparc(...
                                'surface', ...
                                d1,...
                                d2,...
                                f_fsrib,...
                                f_fst1,...
                                f_surfparc,...
                                dirs.fsl,...
                                ofnames_subj, ...
                                FS, ...
                                'WhichPet', WhichPet);

                            S.atlas = ThisAtlas;
                            
                            d = struct;
                            
                            d.lbls = lbls;
                            
                            d.f_parclbls = f_parclbls;
                            
                            savetaufiles(S, d3, [FS.surfspace, '-surf'], d, WhichPet);

                        else
                            
                            fprintf('\n.%s-PET scan skipped since surface parcellation is missing. [ID: %d, tp: %s, atlas: %s]', WhichPet, ID, f_tp, ThisAtlas);
                        end
                    end
            end
    end
    
    cleanup(files_to_cleanup);
end

if exist('files_to_cleanup_after_all_atlases', 'var')

    cleanup(files_to_cleanup_after_all_atlases);
end
end

%==========================================================================
function [DoWhat, WhichSess, IDs] = verifyinputs(DoWhat, sess, I, WhichAtlas, opts)

DirMeta  = opts.DirMeta;

if iscell(DoWhat)

    assert(length(DoWhat)==1, 'One DoWhat at a time.');
    
    DoWhat = DoWhat{:};

else
    
    assert(ischar(DoWhat));
end

DoWhatOptions = {
    'JustFetchMergeExistingFC'
    'JustCheckExistRequiredFiles'
    'BuildParcels_surface'
    'BuildFC_SurfaceSUBJ'
    'ParcellateTauPet_SurfaceSUBJ'
    'ParcellateAmyPet_SurfaceSUBJ'
    };

assert(ismember(DoWhat,DoWhatOptions), 'Unrecongnized DoWhat.');

switch DoWhat

    case 'JustCheckExistRequiredFiles'
    
        assert(length(WhichAtlas)==1); % one atlas & FC-type at a time
end

[IDs, WhichSess] = biofinder_getIDs(sess, DirMeta, true);

IDs = IDs(I);
end

%==========================================================================
function [f_FC_v1, f_FC_v2, d_FC, n_FC_v1, n_FC_v2] = get_fcfile(d_fs, WhichFC, space, atlas)

assert(isequal(space, 'Subject'));

assert(isequal(WhichFC, 'full-session'));

d_FC = fullfile(d_fs, 'HB', 'FC');

[~, ~] = mkdir(d_FC);

n_FC_v1 = [lower(atlas),'.FC.mat'];

f_FC_v1 = fullfile(d_FC, n_FC_v1);

n_FC_v2 = [];

f_FC_v2 = [];
end

%==========================================================================
function savetaufiles(S,f_save,tag,L, WhichPet)

switch WhichPet

    case 'Tau'
    
        TP = S.pet.data.parcels;
        
        save(f_save, 'TP');
    
    case 'Amyloid'
    
        AP = S.pet.data.parcels;
        
        save(f_save, 'AP');
end

fprintf('\n.%s-PET parcels (%s) saved [%s]: %s \n', WhichPet, tag, S.atlas, f_save);

lbls = L.lbls;

save(L.f_parclbls, 'lbls');
end

%==========================================================================
function sts = checkexist_FC(DoWhat,ThisAtlas,opts)

switch DoWhat

    case 'BuildFC_SurfaceSUBJ'

        d1 = exist(opts.f_FC_surface, 'file');
    
        d2 = exist(opts.f_TC_surface, 'file');
        
        dd = [d1, d2];
        
        if all(dd)
        
            fprintf('\n.%s FC_surface file already exists: %s \n', ThisAtlas, opts.f_FC_surface);
            
            fprintf('\n.%s RS_surface file already exists: %s \n', ThisAtlas, opts.f_TC_surface);
            
            sts = 1;
        
        else
        
            sts = 0;
        end
end
end

%==========================================================================
function [f_FC_srf, f_TC_srf] = get_fcfile_surf(d_fs,WhichFC,ThisAtlas,tag_surf)

[~, ~, d_FC, n_FC] = get_fcfile(d_fs, WhichFC, 'Subject', ThisAtlas);

f_FC_srf = fullfile(d_FC, strrep(n_FC, 'FC', ['FC_', tag_surf]));

f_TC_srf = strrep(f_FC_srf, '.FC', '.TC');
end
