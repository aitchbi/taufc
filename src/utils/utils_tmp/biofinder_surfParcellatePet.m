function [f_saves, petparc, lbls] = biofinder_surfParcellatePet(sess_pet, sess_fs, WhichPet, WhichAtlas, dirs, varargin)

d = inputParser;

addParameter(d,'Verbose', true);

addParameter(d,'OverwriteExistingPetParcellation', false);

addParameter(d,'AddFsDateToSavedPetParcFilename', true);

addParameter(d,'WriteResults', true);

addParameter(d,'JustGetFilenames', false);

addParameter(d,'SaveGifti', false);

parse(d,varargin{:});

opts = d.Results;

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

[d_fs_subjs, d_fs, d_fs_orig] = biofinder_getFsDirs(sess_fs, dirs);

switch WhichPet

    case 'Tau'
    
        d_pet_main = fullfile(dirs.pet, 'tnic_sr_mr');
        
        aaa = 'tau_t1';
    
    case 'Amy'
    
        d_pet_main = fullfile(dirs.pet, 'fnc_sr_mr');
        
        aaa = 'amyloid_t1';
end

d_pet = fullfile(d_pet_main, sess_pet);

d_pett1 = fullfile(dirs.pet, aaa, sess_pet);

d_petHB = fullfile(d_pet, 'HB');

d_pett1HB = fullfile(d_pett1, 'HB');

n_pett1 = 't1_reo_resample';

f_pett1 = fullfile(d_pett1, [n_pett1, '.nii.gz']);

switch WhichPet

    case 'Tau'
    
        n_pet = 'suvrat_vox_mean_time_average_1';
        
        f_pet = fullfile(d_pet, [n_pet, '.nii.gz']);

    case 'Amy'
        
        assert(logical(exist(f_pett1, 'file')));

        n_ap_options = {
            'suvrat_vox_mean_time_average_1' 
            'suvrat_vox_mean_time_average_2' 
            'suvrat_vox_mean_time_average_4' 
            };

        for k=1:length(n_ap_options)
            
            n_pet = n_ap_options{k};
            
            f_ap = fullfile(d_pet, [n_pet, '.nii.gz']);
            
            if exist(f_ap, 'file')
            
                amyfound = true;
                
                break;
            
            else
            
                amyfound = false;
            end
        end
        
        assert(amyfound);
        
        f_pet = f_ap;
end

assert(logical(exist(f_pet, 'file')), sprintf('pet file missing: %s', f_pet));

assert(logical(exist(f_pett1, 'file')), sprintf('pet t1 missing: %s', f_pett1));

[~, ~] = mkdir(d_petHB);

[~, ~] = mkdir(d_pett1HB);

tag_surf = 'subjsurf';

atlaslower = lower(WhichAtlas);

switch WhichPet
    
    case 'Tau'
    
        f_tp2fs = fullfile(d_pett1HB, 'tp2fs.mat');
        
        f_petparc = fullfile(d_petHB, sprintf('%s.TP_%s.mat', lower(WhichAtlas), tag_surf));
    
    case 'Amy'
    
        f_ap2fs = fullfile(d_pett1HB, 'ap2fs.mat');
        
        f_petparc = fullfile(d_petHB, sprintf('%s.AP_%s.mat', lower(WhichAtlas), tag_surf));
end

if opts.AddFsDateToSavedPetParcFilename
    
    [~, fsdate] = biofinder_get_sess_id_date(sess_fs);
    
    fstag = ['_FS', num2str(fsdate)];
    
    f_petparc = strrep(f_petparc, '.mat', sprintf('%s.mat', fstag));
end

f_parclbls = fullfile(d_petHB, [atlaslower, '.labels.mat']);

[d, sts] = duplicatefiles(d_fs, d_fs_orig, 'MRI');

if sts == 0
    
    fprintf('\n.FS files missing for: %s', sess_fs);
    
    cleanup(d);
    
    f_saves = [];
    
    petparc = [];
    
    lbls    = [];
    
    return;
else
    
    files_to_cleanup_after_all_atlases = d;
end

f_saves = struct;

f_saves.petparc  = f_petparc;

f_saves.parclbls = f_parclbls;

if opts.JustGetFilenames
    
    petparc = [];
    
    lbls    = [];
    
    return;
end

param = struct;

param.ID = sess_fs; % NOTE1

param.WhichAtlas = WhichAtlas;

param.parallel_nowhere = false;

param.parallel_subjs = false;

param.dir_freesurfer = dirs.freesurfer;

param.dir_fsaverage_hb = dirs.fsaverage_hb;

param.dir_subjs = d_fs_subjs;

param.dir_hbfssh = dirs.hbfssh;

assert(ismember(atlaslower, schaeferyeo7));

param.JustGetRoisName = true;

param = hb_corticalparc(param);

f_fsrib = param.f_refrib;

surfspace = 'subject';

FS = struct;

FS.fsopts.ID = sess_fs;

FS.f_ribbon  = f_fsrib;

FS.surfspace = surfspace;

FS.fsopts.dir_subjs = d_fs_subjs;

FS.fsopts.sh_vol2surf = fullfile(dirs.hbfssh, 'hb_vol2surf.sh');

FS.fsopts.dir_fsavg_hb = dirs.fsaverage_hb;

FS.fsopts.dir_freesurfer = dirs.freesurfer;

FS.tag_surf = tag_surf;

f_fst1 = getfilefst1(d_fs, param, d_fs_orig);

%-FS space-------------------------------------------------------------
tag_reg_fs = 'reslicedToMatchFSRib';

tag_brain_fs = sprintf('.brain.%s.nii.gz', tag_reg_fs);

tag_pet_fs = sprintf('.%s.nii', tag_reg_fs);

f_petfs = fullfile(d_petHB, [n_pet, tag_pet_fs]);

f_pett1brain = fullfile(d_pett1HB, [n_pett1, '.brain.nii.gz']);

f_pett1brainfs = fullfile(d_pett1HB, [n_pett1, tag_brain_fs]);

ofnames_subj = struct;

ofnames_subj.f_petfs = f_petfs;

ofnames_subj.f_pett1brain = f_pett1brain;

ofnames_subj.f_pett1brainfs = f_pett1brainfs;

switch WhichPet

    case 'Tau'
    
        ofnames_subj.f_pet2fs = f_tp2fs;
    
    case 'Amy'
    
        ofnames_subj.f_pet2fs = f_ap2fs;
end

OEPP = opts.OverwriteExistingPetParcellation;

if exist(f_petparc, 'file') && OEPP
    
    delete(f_petparc);
    
    fprintf('\n.Deleting existing %s-PET surface parcellation: %s', WhichPet, f_petparc);
end

f_surfparc = struct;

f_surfparc.lh = param.f_surfrois.lh;

f_surfparc.rh = param.f_surfrois.rh;

chk1 = exist(f_petparc, 'file');

chk2 = exist(f_parclbls, 'file');

if chk1 && chk2

    fprintf('\n.%s-PET surface parcellation & labels exist:', WhichPet);
    
    fprintf('\n.Parc PET : %s', f_petparc);
    
    fprintf('\n.Parc lbls: %s', f_parclbls);
    
    petparc = [];
    
    lbls = [];
    
    if opts.SaveGifti
    
        S = biofinder_pet2petfsparc(...
            'surface', ...
            f_pet,...
            f_pett1,...
            f_fsrib,...
            f_fst1,...
            f_surfparc,...
            dirs.fsl,...
            ofnames_subj, ...
            FS, ...
            'WhichPet', WhichPet, ...
            'SaveGifti', opts.SaveGifti, ...
            'JustGetGifti', true);

        f_saves.petgii = S.f_gii;
    end
else

    chk1 = exist(f_surfparc.lh, 'file');
    
    chk2 = exist(f_surfparc.rh, 'file');

    if chk1 && chk2
    
        [S,~,lbls] = biofinder_pet2petfsparc(...
            'surface', ...
            f_pet,...
            f_pett1,...
            f_fsrib,...
            f_fst1,...
            f_surfparc,...
            dirs.fsl,...
            ofnames_subj, ...
            FS, ...
            'WhichPet', WhichPet, ...
            'SaveGifti', opts.SaveGifti);
        
        if opts.SaveGifti
        
            f_saves.petgii = S.f_gii;
        end
        
        S.atlas = WhichAtlas;
        
        tag = [FS.surfspace, '-surf'];
        
        switch WhichPet
        
            case 'Tau'
            
                TP = S.pet.data.parcels;
                
                if opts.WriteResults
                
                    save(f_petparc, 'TP');
                end
                
                petparc = TP;
            
            case 'Amy'
            
                AP = S.pet.data.parcels;
                
                if opts.WriteResults
                
                    save(f_petparc, 'AP');
                end
                
                petparc = AP;
        end
        
        if opts.WriteResults
        
            save(f_parclbls, 'lbls');
            
            fprintf('\n.%s-PET parcels (%s) saved [%s]: %s', WhichPet, tag, S.atlas, f_petparc);
            
            fprintf('\n.Parcel labels (%s) saved [%s] : %s', tag, S.atlas, f_parclbls);
        end
    
    else
    
        fprintf('\n.%s-PET scan skipped since surface parcellation is missing. [tp: %s, atlas: %s]', WhichPet, f_pet, WhichAtlas);
        
        petparc = [];
        
        lbls    = [];
    end
end

if exist('files_to_cleanup_after_all_atlases', 'var')
    
    cleanup(files_to_cleanup_after_all_atlases);
end
end