clc
clear
close all

%-paths.
%--------------------------------------------------------------------------
demo_dir = fileparts(mfilename('fullpath'));
repo_root = fileparts(fileparts(demo_dir));

addpath(genpath(fullfile(repo_root, 'src')));

assert(exist('run_fitlms', 'file') ~= 0, ...
    'run_fitlms.m not found. check that src/utils/utils_tmp is on the MATLAB path.');

assert(exist('hb_graph_shuffle_v0', 'file') ~= 0, ...
    'hb_graph_shuffle_v0.m not found. check that src/utils/utils_tmp is on the MATLAB path.');

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
n_subjects = 6;

[FC, PET, N, TmplFC, regressors] = local_make_synthetic_inputs(n_regions, n_subjects);

%-options.
%--------------------------------------------------------------------------
opts = struct;

opts.classes = {'synthetic group'};

opts.classes_todo = [];

opts.regressors.tau_offtarget = regressors.tau_offtarget;

opts.regressors.tau_ontarget = regressors.tau_ontarget;

opts.ShuffledSubjAnalysis_DegreeSequencePreserve.do = true;

opts.ShuffledSubjAnalysis_DegreeSequencePreserve.type = 'PreserveDegreeSequence';

opts.ShuffledSubjAnalysis_StrengthSequenceApproxPreserve.do = false;

opts.ShuffledSubjAnalysis_StrengthSequenceApproxPreserve.nstage = [];

opts.ShuffledSubjAnalysis_StrengthSequenceApproxPreserve.niter = [];

opts.ShuffledSubjAnalysis_StrengthSequenceApproxPreserve.temp = [];

opts.NetworkBasedFitlms.do = false;

opts.NetworkBasedFitlms.atlasinfo = [];

opts.SubjectAmyPetAsRegressor.do = false;

opts.ParallelRun = false;

opts.JustFirstNSubjsPerGroup = [];

%-run regional empirical and degree-preserving null FC models.
%--------------------------------------------------------------------------
% this demo uses the same run_fitlms.m option used in the manuscript code.
% the degree-preserving null rewires the subject FC while preserving nodal
% degree, then enters the rewired FC into the same regional FC-PET model.

[FITLMS, TmplFC_proc, rng_setting] = run_fitlms(FC, PET, N, TmplFC, opts);

empirical_r2 = FITLMS{1}.TmplFc_And_SubjFc.r2;

degree_null_r2 = FITLMS{1}.TmplFc_And_DegreeSequencePreserveShuffledSubjFc.r2;

summary_table = table( ...
    mean(empirical_r2(:), 'omitnan'), ...
    mean(degree_null_r2(:), 'omitnan'), ...
    mean(empirical_r2(:) - degree_null_r2(:), 'omitnan'), ...
    'VariableNames', { ...
    'mean_r2_empirical_subject_fc', ...
    'mean_r2_degree_preserving_null_fc', ...
    'delta_r2_empirical_minus_null'});

disp(summary_table)

%-save outputs.
%--------------------------------------------------------------------------
f_mat = fullfile(d_out, 'degree_preserving_fc_null_demo_outputs.mat');

save(f_mat, ...
    'FITLMS', ...
    'TmplFC_proc', ...
    'rng_setting', ...
    'summary_table', ...
    'empirical_r2', ...
    'degree_null_r2', ...
    'FC', ...
    'PET', ...
    'N', ...
    'TmplFC', ...
    'opts');

f_csv = fullfile(d_out, 'degree_preserving_fc_null_demo_summary.csv');

writetable(summary_table, f_csv);

%-plot summary.
%--------------------------------------------------------------------------
f_fig = fullfile(d_out, 'degree_preserving_fc_null_demo_summary.png');

model_mean = [
    mean(empirical_r2(:), 'omitnan')
    mean(degree_null_r2(:), 'omitnan')
    ];

figure('Color', 'w');

bar(model_mean)

set(gca, ...
    'XTick', 1:2, ...
    'XTickLabel', {'empirical subject FC', 'degree-preserving null FC'});

ylabel('corrected R^2');
title('degree-preserving FC null model');

box off

exportgraphics(gcf, f_fig, 'Resolution', 300);

fprintf('\nfile saved: %s\n', f_mat);
fprintf('file saved: %s\n', f_csv);
fprintf('file saved: %s\n', f_fig);

fprintf('\ndemo done.\n');

%==========================================================================
function [FC, PET, N, TmplFC, regressors] = local_make_synthetic_inputs(n_regions, n_subjects)

region_axis = linspace(0, 1, n_regions)';

dist_mat = abs(region_axis - region_axis');

offtarget = 1.00 + 0.05*region_axis;

ontarget = 1.15 + 0.70*(region_axis.^1.5);

regressors = struct;

regressors.tau_offtarget.mean = offtarget;

regressors.tau_ontarget.mean = ontarget;

base_fc = exp(-5*dist_mat);

base_fc = base_fc ./ max(base_fc(:));

base_fc(logical(eye(n_regions))) = 0;

TmplFC = local_threshold_symmetric_fc(base_fc, 0.25);

FC = cell(1, 1);

PET = cell(1, 1);

N = n_subjects;

FC{1} = zeros(n_regions, n_regions, n_subjects);

PET{1} = zeros(n_regions, n_subjects);

for is=1:n_subjects
    
    severity = 0.40 + 0.12*randn;
    
    tau_pattern = offtarget + severity*(ontarget - offtarget);
    
    tau_pattern = local_unit_interval(tau_pattern);
    
    tau_affinity = tau_pattern*tau_pattern';
    
    subject_noise = 0.10*randn(n_regions);
    
    subject_noise = (subject_noise + subject_noise')/2;
    
    fc = base_fc + 0.45*tau_affinity + subject_noise;
    
    fc = max(fc, 0);
    
    fc(logical(eye(n_regions))) = 0;
    
    fc = local_threshold_symmetric_fc(fc, 0.25);
    
    FC{1}(:,:,is) = fc;
    
    fc_component = fc*tau_pattern;
    
    fc_component = local_unit_interval(fc_component);
    
    PET{1}(:,is) = 1.0 + 0.60*tau_pattern + 0.25*fc_component + 0.04*randn(n_regions, 1);
end
end

%==========================================================================
function fc = local_threshold_symmetric_fc(fc, density)

fc = (fc + fc')/2;

fc(logical(eye(size(fc, 1)))) = 0;

I = triu(true(size(fc)), 1);

v = fc(I);

n_keep = max(1, round(density*numel(v)));

[~, idx] = sort(v, 'descend');

keep = false(size(v));

keep(idx(1:n_keep)) = true;

A = zeros(size(fc));

A(I) = v.*keep;

fc = A + A';

if max(fc(:)) > 0
    
    fc = fc ./ max(fc(:));
end
end

%==========================================================================
function x = local_unit_interval(x)

x = x - min(x);

denom = max(x);

if denom > 0
    
    x = x ./ denom;
end
end