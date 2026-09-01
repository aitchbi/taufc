function [r2, mdl, X] = fitols_regional(y, varargin)

y = y(:);

n_predictors = nargin - 1;

assert(n_predictors >= 1, ...
    'at least one regional predictor is required.');

X = zeros(length(y), n_predictors);

for ip=1:n_predictors
    
    x = varargin{ip};
    
    x = x(:);
    
    assert(length(x)==length(y), ...
        'all regional predictors must have the same length as y.');
    
    X(:,ip) = demean2norm(x, false, true);
end

mdl = fitlm(X, y);

r2 = mdl.Rsquared.Adjusted;
end