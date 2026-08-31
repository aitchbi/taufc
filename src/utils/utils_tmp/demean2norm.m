function x = demean2norm(x, DoDemean, Do2norm, ir)

if DoDemean

    x = x - mean(x);
end

if Do2norm

    nx = norm(x);
    
    if nx==0
    
        if exist('ir', 'var')
        
            warning('HB: regressor with zero norm.. ir: %d', ir);
        end
    
    else
    
        x = x/nx;
    end
end
end
