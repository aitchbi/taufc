function FC = biofinder_tc2fc(TC, varargin)

d = inputParser;

addParameter(d, 'ZeroDiag', true);

parse(d,varargin{:});

opts = d.Results;

N = size(TC,2);

FC = corrcoef(TC);

if opts.ZeroDiag

    FC(find(eye(N))) = 0; % 0 diag
end

assert(issymmetric(FC));
end