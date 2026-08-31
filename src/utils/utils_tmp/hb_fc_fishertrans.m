function Y = hb_fc_fishertrans(Y)

if iscell(Y)

    CellInput = true;

else

    Y = {Y};
    
    CellInput = false;
end

C = length(Y);

for ic=1:C

    X = Y{ic};
    
    D = ndims(X);
    
    assert(ismember(D,[2,3]));
    
    assert(size(X,1)==size(X,2));
    
    N = size(X,1);
    
    switch D
    
        case 2
        
            K = 1;
        
        case 3
        
            K = size(X,3);
    end
    
    I = find(eye(N));
    
    for k=1:K
    
        if K==1
        
            d = X;
        
        else
        
            d = X(:,:,k);
        
        end
        
        d(I) = 0; % ensure zero diag
        
        if K==1
        
            X = d;
        
        else
        
            X(:,:,k) = d;
        end
    end
    
    tol = 1e-6;
    
    % atanh input range: (-1,1)
    
    X = min(X,1-tol);
    
    X = max(X,-1+tol);
    
    X = atanh(X);
    
    Y{ic} = X;
end

if ~CellInput

    assert(C==1);
    
    Y = Y{1};
end
end
