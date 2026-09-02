clc
clear
close all

%-paths.
%--------------------------------------------------------------------------
demo_dir = fileparts(mfilename('fullpath'));

d_out = fullfile(demo_dir, 'results');

if ~exist(d_out, 'dir')
    
    mkdir(d_out);
end

%-synthetic inputs.
%--------------------------------------------------------------------------
rng(1)

n_regions = 40;
n_subjects = 8;

[TmplFC, SubjFC, beta_tmpl, beta_subj] = local_make_synthetic_inputs(n_regions, n_subjects);

%-build hybrid FC.
%--------------------------------------------------------------------------
HybridFC = zeros(n_regions, n_regions, n_subjects);

for is=1:n_subjects
    HybridFC(:,:,is) = taufc_func_build_hybrid_fc( ...
    TmplFC, ...
    SubjFC(:,:,is), ...
    beta_tmpl(is,:), ...
    beta_subj(is,:));
end

%-summarize output as a smoke test.
%--------------------------------------------------------------------------
% this summary is not part of the analysis. it is included only as a simple
% check that the hybrid FC matrices are related to both the template FC and
% subject FC, and that the hybrid FC columns were normalized after mixing.

summary_table = local_summarize_hybrid_fc(TmplFC, SubjFC, HybridFC);

%-save outputs.
%--------------------------------------------------------------------------
f_mat = fullfile(d_out, 'hybrid_fc_demo_outputs.mat');

save(f_mat, ...
    'TmplFC', ...
    'SubjFC', ...
    'HybridFC', ...
    'beta_tmpl', ...
    'beta_subj', ...
    'summary_table');

%-plot example subject.
%--------------------------------------------------------------------------
is_plot = 1;

f_fig = fullfile(d_out, 'hybrid_fc_demo_subject_001.png');

figure('Color', 'w');

tiledlayout(1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');

nexttile
imagesc(TmplFC)
axis image off
colorbar
title('template FC')

nexttile
imagesc(SubjFC(:,:,is_plot))
axis image off
colorbar
title('subject FC')

nexttile
imagesc(HybridFC(:,:,is_plot))
axis image off
colorbar
title('hybrid FC')

exportgraphics(gcf, f_fig, 'Resolution', 300);

fprintf('\nfile saved: %s\n', f_mat);
fprintf('file saved: %s\n', f_fig);

fprintf('\ndemo done.\n');

%==========================================================================
function [TmplFC, SubjFC, beta_tmpl, beta_subj] = local_make_synthetic_inputs(n_regions, n_subjects)

region_axis = linspace(0, 1, n_regions)';

dist_mat = abs(region_axis - region_axis');

TmplFC = exp(-4*dist_mat);

TmplFC = TmplFC ./ max(TmplFC(:));

TmplFC = 0.6*TmplFC;

TmplFC(logical(eye(n_regions))) = 0;

SubjFC = zeros(n_regions, n_regions, n_subjects);

beta_tmpl = zeros(n_subjects, n_regions);

beta_subj = zeros(n_subjects, n_regions);

for is=1:n_subjects
    
    subject_noise = 0.06*randn(n_regions);
    
    subject_noise = (subject_noise + subject_noise')/2;
    
    subject_axis = sin(2*pi*(region_axis + rand));
    
    subject_pattern = 0.08*(subject_axis*subject_axis');
    
    fc = TmplFC + subject_pattern + subject_noise;
    
    fc = max(fc, 0);
    
    fc = fc ./ max(fc(:));
    
    fc(logical(eye(n_regions))) = 0;
    
    SubjFC(:,:,is) = fc;
    
    beta_tmpl(is,:) = 0.70 + 0.20*cos(2*pi*region_axis') + 0.04*randn(1, n_regions);
    
    beta_subj(is,:) = 0.35 + 0.20*sin(2*pi*region_axis') + 0.04*randn(1, n_regions);
end
end

%==========================================================================
function summary_table = local_summarize_hybrid_fc(TmplFC, SubjFC, HybridFC)

n_subjects = size(SubjFC, 3);

corr_template_subject = zeros(n_subjects, 1);

corr_template_hybrid = zeros(n_subjects, 1);

corr_subject_hybrid = zeros(n_subjects, 1);

mean_hybrid_column_norm = zeros(n_subjects, 1);

v_tmpl = local_offdiag_vector(TmplFC);

for is=1:n_subjects
    
    v_subj = local_offdiag_vector(SubjFC(:,:,is));
    
    v_hybrid = local_offdiag_vector(HybridFC(:,:,is));
    
    corr_template_subject(is) = local_corr(v_tmpl, v_subj);
    
    corr_template_hybrid(is) = local_corr(v_tmpl, v_hybrid);
    
    corr_subject_hybrid(is) = local_corr(v_subj, v_hybrid);
    
    mean_hybrid_column_norm(is) = mean(vecnorm(HybridFC(:,:,is)));
end

subject = (1:n_subjects)';

summary_table = table( ...
    subject, ...
    corr_template_subject, ...
    corr_template_hybrid, ...
    corr_subject_hybrid, ...
    mean_hybrid_column_norm);
end

%==========================================================================
function v = local_offdiag_vector(X)

I = ~eye(size(X, 1));

v = X(I);
end

%==========================================================================
function r = local_corr(x, y)

x = x(:);

y = y(:);

x = x - mean(x, 'omitnan');

y = y - mean(y, 'omitnan');

r = sum(x.*y, 'omitnan') ./ sqrt(sum(x.^2, 'omitnan') .* sum(y.^2, 'omitnan'));
end