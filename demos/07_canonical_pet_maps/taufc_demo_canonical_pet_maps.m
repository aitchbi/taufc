%-initialize.
%--------------------------------------------------------------------------
clear;
clc;
close all;

repo_root = fileparts(fileparts(fileparts(mfilename('fullpath'))));

addpath(fullfile(repo_root, 'src', 'utils', 'utils_tmp'));

demo_dir = fileparts(mfilename('fullpath'));

d_out = fullfile(demo_dir, 'results');
if ~exist(d_out, 'dir')
    mkdir(d_out);
end

%-simulate parcellated PET data.
%--------------------------------------------------------------------------
rng(1);

n_regions  = 100;
n_subjects = 300;

PET = local_make_synthetic_pet(n_regions, n_subjects);

%-estimate canonical off- and on-target PET patterns.
%--------------------------------------------------------------------------
regions_to_store_gmm = [10 25 50 75];

[TPP, AIC, OFTB, ONTB, GMM] = hb_tp2tpp( ...
    PET, ...
    'WhichRegionalGMMsToReturn', regions_to_store_gmm);

canonical.offtarget = OFTB;
canonical.ontarget  = ONTB;

%-save outputs.
%--------------------------------------------------------------------------
f_out = fullfile(d_out, 'canonical_pet_maps_demo_outputs.mat');

save(f_out, ...
    'PET', ...
    'TPP', ...
    'AIC', ...
    'OFTB', ...
    'ONTB', ...
    'GMM', ...
    'canonical', ...
    'regions_to_store_gmm');

fprintf('\nfile saved: %s\n', f_out);

%-plot canonical maps.
%--------------------------------------------------------------------------
figure('Name', 'canonical PET maps');

plot(OFTB.mean, 'LineWidth', 1.5);
hold on;
plot(ONTB.mean, 'LineWidth', 1.5);
hold off;

xlabel('cortical region');
ylabel('PET SUVR');
legend({'off-target mean', 'on-target mean'}, 'Location', 'best');
title('canonical off- and on-target PET patterns');

f_fig = fullfile(d_out, 'canonical_pet_maps_demo.png');
saveas(gcf, f_fig);

fprintf('figure saved: %s\n', f_fig);

%-plot example regional GMM.
%--------------------------------------------------------------------------
ir = regions_to_store_gmm(1);

if ~isempty(GMM{ir})

    figure('Name', sprintf('regional GMM, region %d', ir));

    histogram(GMM{ir}.tpir, 30, 'Normalization', 'pdf');
    hold on;
    plot(GMM{ir}.tpir_x, GMM{ir}.GMM1.pdf, 'LineWidth', 1.5);
    plot(GMM{ir}.tpir_x, GMM{ir}.GMM2.pdf_left, 'LineWidth', 1.5);
    plot(GMM{ir}.tpir_x, GMM{ir}.GMM2.pdf_right, 'LineWidth', 1.5);
    hold off;

    xlabel('PET SUVR');
    ylabel('density');
    legend({'subjects', '1-component GMM', 'off-target component', 'on-target component'}, ...
        'Location', 'best');
    title(sprintf('example regional GMM, region %d', ir));

    f_fig_gmm = fullfile(d_out, sprintf('regional_gmm_region_%03d.png', ir));
    saveas(gcf, f_fig_gmm);

    fprintf('figure saved: %s\n', f_fig_gmm);
end

fprintf('\ndemo done.\n');

%==========================================================================
function PET = local_make_synthetic_pet(n_regions, n_subjects)

PET = zeros(n_regions, n_subjects);

region_axis = linspace(0, 1, n_regions)';

off_mean = 1.00 + 0.10 * region_axis;
on_mean  = 1.25 + 0.80 * region_axis;

off_sd = 0.04 + 0.02 * region_axis;
on_sd  = 0.08 + 0.04 * region_axis;

p_on = linspace(0.10, 0.55, n_regions)';

for ir = 1:n_regions

    is_on = rand(1, n_subjects) < p_on(ir);

    PET(ir, ~is_on) = off_mean(ir) + off_sd(ir) * randn(1, nnz(~is_on));
    PET(ir,  is_on) = on_mean(ir)  + on_sd(ir)  * randn(1, nnz(is_on));

end

PET(PET < 0.5) = 0.5;

end