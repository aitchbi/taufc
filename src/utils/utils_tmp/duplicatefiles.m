function [files_to_cleanup, sts] = duplicatefiles(d_main,d_main_orig,WhichData)

if isequal(d_main,d_main_orig)

    files_to_cleanup = [];

else

    [~,~] = mkdir(d_main);
    
    switch WhichData

        case 'MRI'
    
            [~,~] = mkdir(fullfile(d_main,'mri'));
            
            [~,~] = mkdir(fullfile(d_main,'surf'));
            
            [~,~] = mkdir(fullfile(d_main,'label'));

            files = {
                fullfile('mri','orig.mgz');
                fullfile('mri','T1.mgz');
                fullfile('mri','ribbon.mgz');
                fullfile('mri','aparc+aseg.mgz');

                fullfile('surf','lh.orig');
                fullfile('surf','lh.pial');
                fullfile('surf','lh.white');
                fullfile('surf','lh.thickness');
                fullfile('surf','lh.sphere.reg');

                fullfile('surf','rh.orig');
                fullfile('surf','rh.pial');
                fullfile('surf','rh.white');
                fullfile('surf','rh.thickness');
                fullfile('surf','rh.sphere.reg');

                fullfile('label','lh.aparc.annot');
                fullfile('label','rh.aparc.annot');
                };

            for k=1:length(files)
                
                f = files{k};
                
                f_fr = fullfile(d_main_orig,f);
                
                f_to = fullfile(d_main,f);
                
                if not(exist(f_to,'file'))
                
                    if exist(f_fr,'file')
                    
                        d = copyfile(f_fr,f_to);
                        
                        assert(d==1, 'Fishy; problem copying file.');
                    
                    else
                    
                        fprintf('\n.Missing file: %s',f_fr);
                        
                        files_to_cleanup = [];
                        
                        sts = 0;
                        
                        return;
                    end
                end
                
                if k==1
                
                    files_to_cleanup = {
                        f_to
                        };
                
                else
                
                    files_to_cleanup = [
                        files_to_cleanup
                        f_to
                        ]; %#ok<*AGROW>
                end
            end

            files_to_cleanup = [
                files_to_cleanup
                fullfile(d_main,'mri','ribbon.nii')
                fullfile(d_main,'surf','lh.pial.surf.gii')
                fullfile(d_main,'surf','lh.white.surf.gii')
                fullfile(d_main,'surf','rh.pial.surf.gii')
                fullfile(d_main,'surf','rh.white.surf.gii')
                ];

        case 'PET'
            % n/a
    end
end

sts = 1;
end