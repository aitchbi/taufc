function S = prunestruct(S, I)

assert(islogical(I));

F = fieldnames(S);

K = length(F);

for k=1:K

    f = F{k};
    
    d = S.(f);
    
    switch class(d)
    
        case {'double', 'cell'}
        
            % e.g. double: age
            % e.g. cell: diagnosis
            
            assert(length(d)==length(I));
            
            d = d(I);
        
        case 'struct'
        
            % e.g. struct: cognitive scores
            
            d = prunestruct(d, I);
        
        otherwise
        
            error('unrecongnised field.');
    end
    
    S.(f) = d;
end
end
