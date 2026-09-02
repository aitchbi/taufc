%==========================================================================
function hybrid_fc = taufc_func_build_hybrid_fc(template_fc, subject_fc, beta_template, beta_subject)
% build hybrid FC from template and subject FC.
%
% the implementation follows the hybrid-FC construction used in run_fitlms.m:
% template and subject FC columns are first normalized, each regional FC
% profile is weighted by the corresponding template-FC and subject-FC beta
% coefficient, and the mixed matrix is column-normalized again.

n_regions = size(template_fc, 1);

assert(isequal(size(template_fc), size(subject_fc)), ...
    'template_fc and subject_fc must have the same dimensions.');

assert(size(template_fc, 1)==size(template_fc, 2), ...
    'template_fc and subject_fc must be square matrices.');

assert(numel(beta_template)==n_regions, ...
    'beta_template must have one value per region.');

assert(numel(beta_subject)==n_regions, ...
    'beta_subject must have one value per region.');

template_fc = local_normalize_columns(template_fc);

subject_fc = local_normalize_columns(subject_fc);

beta_template = reshape(beta_template, 1, []);

beta_subject = reshape(beta_subject, 1, []);

bt = repmat(beta_template, n_regions, 1);

bs = repmat(beta_subject, n_regions, 1);

hybrid_fc = bt.*template_fc + bs.*subject_fc;

hybrid_fc = local_normalize_columns(hybrid_fc);

hybrid_fc(logical(eye(n_regions))) = 0;

end

%==========================================================================
function X = local_normalize_columns(X)

col_norm = vecnorm(X);

col_norm(col_norm==0) = eps;

X = bsxfun(@rdivide, X, col_norm);

end