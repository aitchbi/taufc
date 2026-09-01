clc
clear
close all

%-paths.
%--------------------------------------------------------------------------
demo_dir = fileparts(mfilename('fullpath'));
repo_root = fileparts(fileparts(demo_dir));

addpath(genpath(fullfile(repo_root, 'src')));

assert(exist('fitlhrh', 'file') ~= 0, ...
    'fitlhrh.m not found. check that src/utils/utils_tmp is on the MATLAB path.');

assert(exist('fitols_regional', 'file') ~= 0, ...
    'fitols_regional.m not found. check that src/utils/utils_tmp is on the MATLAB path.');

assert(exist('fitlm', 'file') ~= 0, ...
    'fitlm not found. this demo requires the Statistics and Machine Learning Toolbox.');

d_out = fullfile(demo_dir, 'results');

if ~exist(d_out, 'dir')
    
    mkdir(d_out);
end

%-synthetic inputs.
%--------------------------------------------------------------------------
rng(1)

n_regions = 40;
n_subjects = 5;

[canonical, HybridFC, PET] = local_make_synthetic_inputs(n_regions, n_subjects);

%-compare canonical PET maps and hybrid FC models.
%--------------------------------------------------------------------------
% these are in-sample explanatory OLS fits, not cross-validated prediction.
% the canonical-only model uses regional PET-pattern predictors.
% the hybrid-FC model uses fitlhrh.m.
% the combined model adds canonical PET-pattern predictors to the hybrid-FC
% design matrix, following the same logic used in run_fitlms.m.
%
% note: the synthetic PET data are structured by construction. they contain
% both canonical PET-pattern signal and hybrid-FC-related signal, so the
% combined model is expected to improve. this demo illustrates the
% model-comparison workflow and should not be interpreted as a null
% simulation.

r2_canonical = zeros(n_subjects, 1);
r2_hybrid_fc = zeros(n_subjects, 1);
r2_canonical_hybrid_fc = zeros(n_subjects, 1);

r2_hybrid_fc_lh = zeros(n_subjects, 1);
r2_hybrid_fc_rh = zeros(n_subjects, 1);

r2_canonical_hybrid_fc_lh = zeros(n_subjects, 1);
r2_canonical_hybrid_fc_rh = zeros(n_subjects, 1);

for is=1:n_subjects
    
    tpicis = PET(:,is);
    
    r2_canonical(is) = fitols_regional( ...
        tpicis, ...
        canonical.offtarget_mean, ...
        canonical.ontarget_mean);
    
    [r2l, r2r] = fitlhrh(HybridFC(:,:,is), tpicis);
    
    r2_hybrid_fc_lh(is) = r2l;
    r2_hybrid_fc_rh(is) = r2r;
    r2_hybrid_fc(is)    = mean([r2l r2r]);
    
    [r2l, r2r] = fitlhrh( ...
        HybridFC(:,:,is), ...
        tpicis, ...
        canonical.offtarget_mean, ...
        canonical.ontarget_mean);
    
    r2_canonical_hybrid_fc_lh(is) = r2l;
    r2_canonical_hybrid_fc_rh(is) = r2r;
    r2_canonical_hybrid_fc(is)    = mean([r2l r2r]);
end

summary_table = table( ...
    (1:n_subjects)', ...
    r2_canonical, ...
    r2_hybrid_fc, ...
    r2_canonical_hybrid_fc, ...
    r2_canonical_hybrid_fc - r2_canonical, ...
    r2_canonical_hybrid_fc - r2_hybrid_fc, ...
    'VariableNames', { ...
    'subject', ...
    'r2_canonical', ...
    'r2_hybrid_fc', ...
    'r2_canonical_hybrid_fc', ...
    'delta_r2_combined_minus_canonical', ...
    'delta_r2_combined_minus_hybrid_fc'});

disp(summary_table)

%-save outputs.
%--------------------------------------------------------------------------
f_mat = fullfile(d_out, 'canonical_vs_hybrid_models_demo_outputs.mat');

save(f_mat, ...
    'canonical', ...
    'HybridFC', ...
    'PET', ...
    'summary_table', ...
    'r2_canonical', ...
    'r2_hybrid_fc', ...
    'r2_canonical_hybrid_fc', ...
    'r2_hybrid_fc_lh', ...
    'r2_hybrid_fc_rh', ...
    'r2_canonical_hybrid_fc_lh', ...
    'r2_canonical_hybrid_fc_rh');

f_csv = fullfile(d_out, 'canonical_vs_hybrid_models_demo_summary.csv');

writetable(summary_table, f_csv);

%-plot summary.
%--------------------------------------------------------------------------
f_fig = fullfile(d_out, 'canonical_vs_hybrid_models_demo_summary.png');

model_mean = [
    mean(r2_canonical)
    mean(r2_hybrid_fc)
    mean(r2_canonical_hybrid_fc)
    ];

model_sem = [
    std(r2_canonical)./sqrt(n_subjects)
    std(r2_hybrid_fc)./sqrt(n_subjects)
    std(r2_canonical_hybrid_fc)./sqrt(n_subjects)
    ];

figure('Color', 'w');

bar(model_mean)
hold on
errorbar(1:3, model_mean, model_sem, 'k.', 'LineWidth', 1.2)
hold off

set(gca, ...
    'XTick', 1:3, ...
    'XTickLabel', {'canonical PET maps', 'hybrid FC', 'canonical + hybrid FC'});

ylabel('corrected R^2');
title('canonical PET maps vs hybrid FC models');

box off

exportgraphics(gcf, f_fig, 'Resolution', 300);

fprintf('\nfile saved: %s\n', f_mat);
fprintf('file saved: %s\n', f_csv);
fprintf('file saved: %s\n', f_fig);

fprintf('\ndemo done.\n');

%==========================================================================
function [canonical, HybridFC, PET] = local_make_synthetic_inputs(n_regions, n_subjects)

region_axis = linspace(0, 1, n_regions)';

canonical = struct;

canonical.offtarget_mean = 1.00 + 0.05*region_axis;

canonical.ontarget_mean = 1.15 + 0.65*(region_axis.^1.4);

dist_mat = abs(region_axis - region_axis');

TmplFC = exp(-4*dist_mat);

TmplFC = TmplFC ./ max(TmplFC(:));

TmplFC = 0.6*TmplFC;

TmplFC(logical(eye(n_regions))) = 0;

HybridFC = zeros(n_regions, n_regions, n_subjects);

PET = zeros(n_regions, n_subjects);

seed_weights = exp(-5*abs(region_axis - 0.65));

seed_weights = seed_weights ./ norm(seed_weights);

for is=1:n_subjects
    
    subject_noise = 0.06*randn(n_regions);
    
    subject_noise = (subject_noise + subject_noise')/2;
    
    subject_axis = sin(2*pi*(region_axis + rand));
    
    subject_pattern = 0.08*(subject_axis*subject_axis');
    
    SubjFC = TmplFC + subject_pattern + subject_noise;
    
    SubjFC = max(SubjFC, 0);
    
    SubjFC = SubjFC ./ max(SubjFC(:));
    
    SubjFC(logical(eye(n_regions))) = 0;
    
    beta_tmpl = 0.70 + 0.20*cos(2*pi*region_axis') + 0.04*randn(1, n_regions);
    
    beta_subj = 0.35 + 0.20*sin(2*pi*region_axis') + 0.04*randn(1, n_regions);
    
    HybridFC(:,:,is) = local_build_hybrid_fc(TmplFC, SubjFC, beta_tmpl, beta_subj);
    
    hybrid_component = HybridFC(:,:,is)*seed_weights;
    
    hybrid_component = local_unit_interval(hybrid_component);
    
    severity = 0.45 + 0.15*randn;
    
    PET(:,is) = ...
        canonical.offtarget_mean + ...
        severity*(canonical.ontarget_mean - canonical.offtarget_mean) + ...
        0.35*hybrid_component + ...
        0.04*randn(n_regions, 1);
end
end

%==========================================================================
function HybridFC = local_build_hybrid_fc(TmplFC, SubjFC, beta_tmpl, beta_subj)

n_regions = size(TmplFC, 1);

TmplFC = TmplFC ./ max(vecnorm(TmplFC), eps);

SubjFC = SubjFC ./ max(vecnorm(SubjFC), eps);

beta_tmpl = reshape(beta_tmpl, 1, []);

beta_subj = reshape(beta_subj, 1, []);

bt = repmat(beta_tmpl, n_regions, 1);

bs = repmat(beta_subj, n_regions, 1);

HybridFC = bt.*TmplFC + bs.*SubjFC;

HybridFC = HybridFC ./ max(vecnorm(HybridFC), eps);

HybridFC(logical(eye(n_regions))) = 0;
end

%==========================================================================
function x = local_unit_interval(x)

x = x - min(x);

denom = max(x);

if denom > 0
    
    x = x ./ denom;
end
end