function [FC, opts] = processfc(FC, opts)

if iscell(FC)

    Nc = length(FC);
    
    for ic=1:Nc
    
        FC{ic}(FC{ic}<0) = 0;
    end

else

    FC(FC<0) = 0;
end

opts.AbsoluteValueFC = false;

opts.PositiveValueFC = true;

opts.thresh_FC = [];

opts.density_FC = [];

opts.knn_FC = [];
end
