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

class_labels = {
    'CN Abeta-'
    'MCI Abeta+'
    'ADD Abeta+'};

N = [4 4 4];

[FC, PET, TmplFC, regressors] = local_make_synthetic_inputs(n_regions, N);

%-options.
%--------------------------------------------------------------------------
opts = struct;

opts.classes = class_labels;

opts.classes_todo = [];

opts.regressors.tau_offtarget = regressors.tau_offtarget;

opts.regressors.tau_ontarget = regressors.tau_ontarget;

opts.ShuffledSubjAnalysis_DegreeSequencePreserve.do = false;

opts.ShuffledSubjAnalysis_DegreeSequencePreserve.type = [];

opts.ShuffledSubjAnalysis_StrengthSequenceApproxPreserve.do = false;

opts.ShuffledSubjAnalysis_StrengthSequenceApproxPreserve.nstage = [];

opts.ShuffledSubjAnalysis_StrengthSequenceApproxPreserve.niter = [];

opts.ShuffledSubjAnalysis_StrengthSequenceApproxPreserve.temp = [];

opts.NetworkBasedFitlms.do = false;

opts.NetworkBasedFitlms.atlasinfo = [];

opts.SubjectAmyPetAsRegressor.do = false;

opts.ParallelRun = false;

opts.JustFirstNSubjsPerGroup = [];

%-run regional FC--PET fits.
%--------------------------------------------------------------------------
[FITLMS, TmplFC_proc, rng_setting] = run_fitlms(FC, PET, N, TmplFC, opts);

summary_table = local_summarize_fitlms(FITLMS, class_labels);

disp(summary_table)

%-save outputs.
%--------------------------------------------------------------------------
f_mat = fullfile(d_out, 'regional_fc_pet_fits_demo_outputs.mat');

save(f_mat, ...
    'FITLMS', ...
    'TmplFC_proc', ...
    'rng_setting', ...
    'summary_table', ...
    'class_labels', ...
    'N', ...
    'opts');

f_csv = fullfile(d_out, 'regional_fc_pet_fits_demo_summary.csv');

writetable(summary_table, f_csv);

%-plot summary.
%--------------------------------------------------------------------------
f_fig = fullfile(d_out, 'regional_fc_pet_fits_demo_summary.png');

x = categorical(summary_table.group);

x = reordercats(x, summary_table.group);

figure('Color', 'w');

bar(x, [
    summary_table.mean_r2_template_fc ...
    summary_table.mean_r2_subject_fc ...
    summary_table.mean_r2_template_subject_fc
    ]);

ylabel('corrected R^2');

legend( ...
    {'template FC', 'subject FC', 'template FC + subject FC'}, ...
    'Location', 'northwest');

title('regional FC--PET model fits');

box off

exportgraphics(gcf, f_fig, 'Resolution', 300);

fprintf('\nfile saved: %s\n', f_mat);

fprintf('file saved: %s\n', f_csv);

fprintf('file saved: %s\n', f_fig);

fprintf('\ndemo done.\n');

%==========================================================================
function [FC, PET, TmplFC, regressors] = local_make_synthetic_inputs(n_regions, N)

n_classes = length(N);

region_axis = linspace(0, 1, n_regions)';

dist_mat = abs(region_axis - region_axis');

base_fc = exp(-4*dist_mat);

base_fc = base_fc ./ max(base_fc(:));

base_fc = 0.55*base_fc;

base_fc(logical(eye(n_regions))) = 0;

offtarget = 1.00 + 0.05*region_axis;

ontarget = 1.15 + 0.65*(region_axis.^1.4);

regressors = struct;

regressors.tau_offtarget.mean = offtarget;

regressors.tau_ontarget.mean = ontarget;

FC = cell(n_classes, 1);

PET = cell(n_classes, 1);

group_tau_load = [0.15 0.55 0.90];

group_fc_scale = [1.00 0.93 0.87];

for ic=1:n_classes
    
    FC{ic} = zeros(n_regions, n_regions, N(ic));
    
    PET{ic} = zeros(n_regions, N(ic));
    
    for is=1:N(ic)
        
        subject_noise = 0.035*randn(n_regions);
        
        subject_noise = (subject_noise + subject_noise')/2;
        
        subject_bias = 0.04*(region_axis*region_axis');
        
        fc_raw = group_fc_scale(ic)*base_fc + subject_bias + subject_noise;
        
        fc_raw = max(min(fc_raw, 0.85), 0);
        
        fc_raw(logical(eye(n_regions))) = 0;
        
        FC{ic}(:,:,is) = local_fisher_zerodiag(fc_raw);
        
        connectivity_component = fc_raw*ontarget;
        
        connectivity_component = local_unit_interval(connectivity_component);
        
        severity = group_tau_load(ic) + 0.08*randn;
        
        pet_vector = offtarget + severity*(ontarget - offtarget) + 0.12*connectivity_component + 0.04*randn(n_regions, 1);
        
        PET{ic}(:,is) = pet_vector;
    end
end

TmplFC_raw = mean(local_unfisher_stack(FC{1}), 3);

TmplFC = local_fisher_zerodiag(TmplFC_raw);
end

%==========================================================================
function fc = local_fisher_zerodiag(fc)

fc = max(min(fc, 0.999), -0.999);

fc = atanh(fc);

fc(logical(eye(size(fc, 1)))) = 0;
end

%==========================================================================
function FC_raw = local_unfisher_stack(FC_z)

FC_raw = tanh(FC_z);
end

%==========================================================================
function x = local_unit_interval(x)

x = x - min(x);

denom = max(x);

if denom > 0
    
    x = x ./ denom;
end
end

%==========================================================================
function summary_table = local_summarize_fitlms(FITLMS, class_labels)

n_classes = length(FITLMS);

mean_r2_template_fc = zeros(n_classes, 1);

mean_r2_subject_fc = zeros(n_classes, 1);

mean_r2_template_subject_fc = zeros(n_classes, 1);

for ic=1:n_classes
    
    mean_r2_template_fc(ic) = mean(FITLMS{ic}.TmplFc.r2(:), 'omitnan');
    
    mean_r2_subject_fc(ic) = mean(FITLMS{ic}.SubjFc.r2(:), 'omitnan');
    
    mean_r2_template_subject_fc(ic) = mean(FITLMS{ic}.TmplFc_And_SubjFc.r2(:), 'omitnan');
end

summary_table = table( ...
    class_labels(:), ...
    mean_r2_template_fc, ...
    mean_r2_subject_fc, ...
    mean_r2_template_subject_fc, ...
    mean_r2_template_subject_fc - mean_r2_template_fc, ...
    'VariableNames', { ...
    'group', ...
    'mean_r2_template_fc', ...
    'mean_r2_subject_fc', ...
    'mean_r2_template_subject_fc', ...
    'delta_r2_template_subject_minus_template'});
end