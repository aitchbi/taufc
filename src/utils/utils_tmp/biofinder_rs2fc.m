function [FC_v1, FC_v2, TC_v1, TC_v2, S, lbls] = biofinder_rs2fc(type, S, f_parc, WhichFC, varargin)

d = inputParser;

addParameter(d, 'WhichSpace', 'subject'); 

parse(d,varargin{:});

opts = d.Results;

assert(isequal(opts.WhichSpace, 'subject'));

assert(isequal(type, 'surface'));

assert(isequal(WhichFC, 'full-session'));
    
[p_lh, lbls_lh] = hb_gii2parc(S.rsfmri.data.lh, f_parc.lh);

[p_rh, lbls_rh] = hb_gii2parc(S.rsfmri.data.rh, f_parc.rh);

TC_v1 = [
    p_lh
    p_rh];

TC_v2 = [];

lbls = [
    lbls_lh(:)
    lbls_rh(:)
    ];

S.rsfmri.parcels_v1 = TC_v1;

S.rsfmri.parcels_v2 = TC_v2;

FC_v1 = getfcfull(TC_v1);

FC_v2 = [];

assert(issymmetric(FC_v1));
end

%==========================================================================
function FC = getfcfull(TC)
Np = size(TC,1);

FC = biofinder_tc2fc(TC', 'ZeroDiag', 1);

FC(find(eye(Np))) = 0; % 0 diag

assert(size(FC,1)==Np);
end
