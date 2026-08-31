function [FC_class, PET_class, INFO_class, sess_pet_class, sess_rs_class, N_class] = fc_exclude_fishy(FC_class, PET_class, INFO_class, sess_pet_class, sess_rs_class, N_class, lbls)

lunique = zeros(sum(N_class), 1);

icount = 0;
Nc = length(N_class);

for ic=1:Nc

    Nic = N_class(ic);
    
    fcic = FC_class{ic};
    
    for is=1:Nic
    
        icount = icount+1;
        
        d = fcic(:,:,is);
        
        lunique(icount) = length(unique(d(:)));
    end
end

munique = median(lunique);

for ic=1:Nc

    Nic = N_class(ic);
    
    fcic = FC_class{ic};
    
    I = false(Nic,1);
    
    for is=1:Nic
    
        d = fcic(:,:,is);
        
        d = length(unique(d(:)));
        
        if d<(0.01*munique)
            
            % FC has a very fishy weight distribution; exclude subject
        
            I(is) = true; 
        end
    end

    if any(I)
    
        FC_class{ic}(:,:,I) = [];
        
        PET_class{ic}(:,I)  = [];
        
        INFO_class{ic} = prunestruct(INFO_class{ic}, not(I));
        
        sess_pet_class{ic} = sess_pet_class{ic}(not(I));
        
        sess_rs_class{ic}  = sess_rs_class{ic}(not(I));
        
        N_class(ic) = N_class(ic) - nnz(I);
        
        d = N_class(ic);
        
        assert(d==size(FC_class{ic}, 3));
        
        assert(d==size(PET_class{ic}, 2));
        
        assert(d==length(INFO_class{ic}.diagnosis));
        
        assert(d==length(sess_pet_class{ic}));
        
        assert(d==length(sess_rs_class{ic}));
        
        fprintf('\n.Number of subjects excluded due to fishy distribution of FC edge weights: %d [class: %s]', nnz(I), lbls{ic});
    end
end
end