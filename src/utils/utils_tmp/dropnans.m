function [FC, TP, INFO, sess_pet, sess_rs, N_class, N_class_before] = dropnans(FC, TP, INFO, sess_pet, sess_rs)

if ~iscell(FC)
    
    FC = {FC};

end

Nc = length(FC);

if ~iscell(TP)

    assert(Nc==1);
    
    TP = {TP};
end

if ~iscell(INFO)
    
    assert(Nc==1);
    
    INFO = {INFO};
end

assert(iscell(sess_pet));

assert(iscell(sess_rs));

N_class_before = zeros(Nc,1);

N_class = zeros(Nc,1);

for iClass=1:Nc

    d1 = [];
    
    d2 = [];
    
    M = size(FC{iClass},3);
    
    assert(size(TP{iClass},2)==M);
    
    N_class_before(iClass) = M;
    
    for iS=1:M
    
        d = FC{iClass}(:,:,iS);
        
        if any(isnan(d(:)))
        
            d1 = [d1 iS]; %#ok<AGROW> 
        end
        
        d = TP{iClass}(:,iS);
        
        if any(isnan(d(:)))
        
            d2 = [d2 iS]; %#ok<AGROW> 
        end
    end
    
    I_drop = sort(union(d1, d2));
    
    I_keep = setdiff(1:M, I_drop);
    
    FC{iClass} = FC{iClass}(:,:,I_keep);
    
    TP{iClass} = TP{iClass}(:,I_keep);
    
    N_class(iClass) = length(I_keep);
    
    I = false(M,1);
    
    I(I_keep) = true;
    
    INFO{iClass} = prunestruct(INFO{iClass}, I);
    
    sess_pet{iClass} = sess_pet{iClass}(I);
    
    sess_rs{iClass} = sess_rs{iClass}(I);
end
end
