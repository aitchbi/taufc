function [TPP, AIC, OFTB, ONTB, GMM] = hb_tp2tpp(PET, varargin)
% HB_TP2TPP transforms PET SUVR values to pet-positive probabilities based
% on 2-component Gaussian mixture modelling as in [1], and it also
% generates two canonical PET maps, representing the off- & on-target
% binding patterns.
% 
% PET: tau/amy-PET SUVR matrix: regions x subjects

p = inputParser;

addParameter(p, 'WhichRegionalGMMsToReturn', []);

parse(p,varargin{:});

opts = p.Results;

Nr = size(PET,1);

Z = zeros(Nr,1);

TPP = zeros(size(PET)); % tau-positive probability

AIC = struct;

AIC.diff = Z;

AIC.best = Z;

AIC.best_model = Z; % 1- or 2-component

OFTB = struct;

OFTB.mean = Z;

OFTB.std = Z;

ONTB = struct;

ONTB.mean = Z;

ONTB.std = Z;

GMM = cell(Nr, 1);

Nx = 1000;

for ir=1:Nr

    tpir = PET(ir,:)'; % tau-PET SUVRs
    
    %-fit GMMs.
    %----------------------------------------------------------------------
    atmp = 0;
    
    while 1
    
        gm1 = fitgmdist(tpir, 1);
        
        gm2 = fitgmdist(tpir, 2, 'RegularizationValue', 1e-5);
        
        if all(gm2.mu < prctile(tpir, 99.5))
        
            break;
        
        else
        
            % NOTE 1
            
            atmp = atmp+1;
            
            fprintf('Ontarget mean too high. Re-fitting; attempt %d\n', atmp);
        end
    end

    %-get AICs.
    %----------------------------------------------------------------------
    if gm1.AIC < gm2.AIC
        
        AIC.diff(ir) = gm1.AIC - gm2.AIC;
        
        AIC.best(ir) = gm1.AIC;
        
        AIC.best_model(ir) = 1;
    
    elseif gm1.AIC > gm2.AIC
    
        AIC.diff(ir) = gm2.AIC - gm1.AIC;
        
        AIC.best(ir) = gm2.AIC;
        
        AIC.best_model(ir) = 2;
    
    else
    
        error('handle equality');
    end

    %-components order (off, on).
    %----------------------------------------------------------------------
    if gm2.mu(1) < gm2.mu(2)
        
        co = [1 2];
        
        comp_order_lbl = {'left' 'right'};
    else
        
        co = [2 1];
        
        comp_order_lbl = {'right' 'left'};
    end

    %-off/On-target binding.
    %----------------------------------------------------------------------
    OFTB.mean(ir) = gm2.mu(co(1));
    
    ONTB.mean(ir) = gm2.mu(co(2));
    
    OFTB.std(ir)  = sqrt(gm2.Sigma(co(1))); % NOTE 2
    
    ONTB.std(ir)  = sqrt(gm2.Sigma(co(2)));

    %-get tau-positive probabilities.
    %----------------------------------------------------------------------
    [idx, ~, pprob] = cluster(gm2, tpir); % NOTE 3
    
    TPP(ir,:) = pprob(:, co(2))';

    if ismember(ir, opts.WhichRegionalGMMsToReturn)
    
        x = linspace(min(tpir), max(tpir), Nx);
        
        GMM{ir} = struct;
        
        GMM{ir}.tpir = tpir;
        
        GMM{ir}.tpir_x = x;
        
        GMM{ir}.GMM1.model = gm1;
        
        GMM{ir}.GMM1.pdf = pdf(gm1, x');
        
        GMM{ir}.GMM2.model = gm2;
        
        GMM{ir}.GMM2.comp_order = co;
        
        GMM{ir}.GMM2.comp_order_lbl = comp_order_lbl;
        
        GMM{ir}.GMM2.pdf_left = normpdf(x, gm2.mu(co(1)), sqrt(gm2.Sigma(co(1))));
        
        GMM{ir}.GMM2.pdf_right = normpdf(x, gm2.mu(co(2)), sqrt(gm2.Sigma(co(2))));
        
        GMM{ir}.GMM2.cluster_assign_left = idx==co(1);
        
        GMM{ir}.GMM2.cluster_assign_right = idx==co(2);
        
        GMM{ir}.GMM2.cluster_probability_left = pprob(:, co(1));
        
        GMM{ir}.GMM2.cluster_probability_right = pprob(:, co(2));
    end
end
end

%-NOTES---------------------------------------------------------------------
% 
% [NOTE 1] a pdf with a mean above 99.5% percentile is fishy; and 99 seems
% to be too low to fetch this particular error. the problem is that
% sometimes, extremely rarely, the upper end pdf becomes erronous and
% become like a spike localized on the largest suvr value. re-running the
% fit generally resolves the issue.

% [NOTE 2] sigma is the covaraince matrix, but since our data is 1D, it's
% just a single value, i.e, varaince, the sqrt of which gives the std of
% the fitted Gaussian.
% 
% [NOTE 3] [idx, nlogL, pprob] = cluster(gm2, tpir);
% partitions tpir into 2 clusters determined by the 2 componnets in gm2. 
% -idx: cluster index of each observation, i.e., the GMM component with the
% largest posterior probability for each given observation.
% -nlogL: the negative loglikelihood of gm2 given the data tpir.
% -pprob: the posterior probabilities of each GMM component given each
% observation.
%--------------------------------------------------------------------------
