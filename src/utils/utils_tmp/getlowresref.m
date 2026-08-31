function f_fst1_ref = getlowresref(WhichRes, dir_subjs, sess_v1, dirs)

if isempty(WhichRes)

    f_fst1_ref = [];

else

    f_fst1_ref = fullfile(dir_subjs, sess_v1, 'mri', sprintf('T1_res%s.nii.gz',WhichRes));

    if not(exist(f_fst1_ref,'file'))

        f_fst1mgz = fullfile(dir_subjs, sess_v1, 'mri','T1.mgz');

        switch WhichRes
    
            case '1000'
            
                voxsize = 1;
            
            case '2000'
            
                voxsize = 2;
            
            case '3000'
            
                voxsize = 3;
        end

        cmd = sprintf(...
            '%s -d %s -r %s -i %s -o %s -v %d',...
            fullfile(dirs.hbfssh, 'hb_fs_mri_convert_resample.sh'),...
            dir_subjs,...
            dirs.freesurfer,...
            f_fst1mgz,...
            f_fst1_ref,...
            voxsize); % isotropic vox size

        hb_runcmd(cmd,'Error converting & resampling mgz file.');
    end
end
end
