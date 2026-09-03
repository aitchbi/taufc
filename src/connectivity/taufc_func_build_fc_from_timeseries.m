function [FC, out] = taufc_func_build_fc_from_timeseries(parcel_ts, varargin)
% build parcel-by-parcel FC from regional time series.
%
% parcel_ts is expected to be regions x timepoints.

p = inputParser;

addRequired(p, 'parcel_ts', @(x) isnumeric(x) && ismatrix(x));
addParameter(p, 'ZeroDiag', true, @(x) islogical(x) && isscalar(x));
addParameter(p, 'PositiveOnly', false, @(x) islogical(x) && isscalar(x));
addParameter(p, 'FisherZ', false, @(x) islogical(x) && isscalar(x));

parse(p, parcel_ts, varargin{:});

zero_diag = p.Results.ZeroDiag;
positive_only = p.Results.PositiveOnly;
fisher_z = p.Results.FisherZ;

%-check input.
%--------------------------------------------------------------------------
n_regions = size(parcel_ts, 1);
n_timepoints = size(parcel_ts, 2);

assert(n_regions > 1, ...
    'parcel_ts must contain more than one region.');

assert(n_timepoints > 2, ...
    'parcel_ts must contain more than two timepoints.');

assert(all(isfinite(parcel_ts(:))), ...
    'parcel_ts contains NaN or Inf values.');

%-build FC.
%--------------------------------------------------------------------------
FC = corrcoef(parcel_ts');

if zero_diag
    
    FC(logical(eye(n_regions))) = 0;
end

if positive_only
    
    FC(FC < 0) = 0;
end

if fisher_z
    
    FC = max(min(FC, 0.999999), -0.999999);
    
    FC = atanh(FC);
    
    if zero_diag
        
        FC(logical(eye(n_regions))) = 0;
    end
end

assert(isequal(size(FC), [n_regions n_regions]), ...
    'unexpected FC matrix size.');

%-collect output.
%--------------------------------------------------------------------------
out = struct;

out.n_regions = n_regions;
out.n_timepoints = n_timepoints;
out.zero_diag = zero_diag;
out.positive_only = positive_only;
out.fisher_z = fisher_z;

end