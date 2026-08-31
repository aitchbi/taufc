function Y = hb_fc_zerodiag(Y)

if iscell(Y)

    CellInput = true;

else

    Y = {Y};
    
    CellInput = false;
end

C = length(Y);

for ic=1:C

    X = Y{ic};
    
    assert(ismember(ndims(X), [2,3]));
    
    assert(size(X,1) == size(X,2));
    
    N = size(X,1);
    
    I = find(eye(N));
    
    switch ndims(X)
    
        case 2
        
            X(I) = 0;
        
        case 3
        
            K = size(X,3);
            
            for k=1:K
            
                d = X(:,:,k);
                
                d(I) = 0;
                
                X(:,:,k) = d;
            end
    end
    
    Y{ic} = X;
end

if ~CellInput

    assert(C==1);
    
    Y = Y{1};
end
end