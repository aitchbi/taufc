function [FITLMS, TmplFC_proc, rng_setting] = run_fitlms(FC, PET, N, TmplFC, opts, varargin)

d = inputParser;

addParameter(d,'SubjectHasPet', []);

addParameter(d,'PrecomputedMixFC', []);

parse(d,varargin{:});

opts2 = d.Results;

opts.PrecomputedMixFC = opts2.PrecomputedMixFC;

rng_setting = rng(1);

Nc = length(FC);

if isempty(opts2.SubjectHasPet)

    SubjectHasPet = cell(size(PET));
    
    for ic=1:Nc
    
        SubjectHasPet{ic} = true(N(ic),1);
    end

else
    
    SubjectHasPet = opts2.SubjectHasPet;
    
    for ic=1:Nc
    
        d = SubjectHasPet{ic};
        
        d1 = all(islogical(d));
        
        d2 = all(ismember(d, [0 1]));
        
        assert(or(d1,d2));
        
        assert(length(d)==N(ic));
    end
end

opts.SubjectHasPet = SubjectHasPet;

[TmplFC_proc, opts] = processfc(TmplFC, opts);

if ~iscell(TmplFC_proc)
    
    d = TmplFC_proc;
    
    TmplFC_proc = cell(Nc, 1);
    
    for ic=1:Nc
    
        TmplFC_proc{ic} = d;
    end
end

FITLMS = cell(Nc,1);

for ic=1:Nc

    FITLMS{ic} = run_fitlms_pvt(PET{ic}, FC, N, ic, TmplFC_proc{ic}, opts);
    
    fprintf('\n.Class done: %s [%d subjects]\n', opts.classes{ic}, N(ic));
end
end

%==========================================================================
function OUT = run_fitlms_pvt(PET, FC, N, ic, TmplFC_proc, opts)

SubjectHasPet = opts.SubjectHasPet{ic};

d1 = isempty(opts.classes_todo);

d2 = ismember(opts.classes{ic}, opts.classes_todo);

if not(or(d1,d2))
    
    OUT = [];
    
    return;
end

[fcall, Nall, fclbls] = getallfc(FC, N);

Nr = length(PET(:,1));

ncic = N(ic);

OUT = initFitlms(ncic, Nr, opts);

DoSubjFc = true;

DoTmplFc = true;

Keep = true(Nr);

Keep(logical(eye(Nr))) = 0;

zncicnr = zeros(ncic, Nr);

if isempty(opts.JustFirstNSubjsPerGroup)
    
    N_subjs_to_run = ncic;
else
    
    N_subjs_to_run = opts.JustFirstNSubjsPerGroup;
    
    fprintf('\n.Run on %d subjects per class.', N_subjs_to_run);
end

if opts.SubjectAmyPetAsRegressor.do

    AP = opts.SubjectAmyPetAsRegressor.AmyPetClass{ic};
end

for is=1:N_subjs_to_run

    tpicis = PET(:,is);

    if not(SubjectHasPet(is))

        assert(all(tpicis==-1), 'fishy; all should be -1'); 
        
        continue;
    end

    if opts.SubjectAmyPetAsRegressor.do
        
        apicis = AP(:,is);
    end

    for iall=1:Nall
        
        d1 = fclbls(1,iall)==ic;
        
        d2 = fclbls(2,iall)==is;
        
        if and(d1, d2)
        
            fcicis = processfcis(fcall(:,:,iall), opts);

            break;
        end
    end

    if opts.ShuffledSubjAnalysis_DegreeSequencePreserve.do

        assert(isequal(opts.ShuffledSubjAnalysis_DegreeSequencePreserve.type, 'PreserveDegreeSequence'));
        
        [fcicis_shuffle_DegreeSequencePreserve_hb, outs1] = hb_graph_shuffle_v0(fcicis, 'Type', 'PreserveDegreeSequence', 'DebugMode', false, 'Verbose', false);
    
        if is==1
        
            OUT.TmplFc_And_DegreeSequencePreserveShuffledSubjFc.number_of_edgepairs_maxswap = zeros(1, ncic);
            
            OUT.TmplFc_And_DegreeSequencePreserveShuffledSubjFc.number_of_edgepairs_rewire = zeros(1, ncic);
            
            OUT.TmplFc_And_DegreeSequencePreserveShuffledSubjFc.number_of_edgepairs_weightswap = zeros(1, ncic);
        end

        OUT.TmplFc_And_DegreeSequencePreserveShuffledSubjFc.number_of_edgepairs_maxswap(is) = outs1.n_edgepairs_maxswap;
        
        OUT.TmplFc_And_DegreeSequencePreserveShuffledSubjFc.number_of_edgepairs_rewire(is) = outs1.n_edgepairs_rewire;
        
        OUT.TmplFc_And_DegreeSequencePreserveShuffledSubjFc.number_of_edgepairs_weightswap(is) = outs1.n_edgepairs_weightswap;
    end

    if opts.ShuffledSubjAnalysis_StrengthSequenceApproxPreserve.do

        if ~exist('fcicis_shuffle_DegreeSequencePreserve_hb','var')

            assert(not(opts.ShuffledSubjAnalysis_DegreeSequencePreserve.do));
            
            fcicis_shuffle_DegreeSequencePreserve_hb = hb_graph_shuffle_v0(fcicis, 'Type', 'PreserveDegreeSequence', 'DebugMode', false, 'Verbose', false);
        end

        nstage = opts.ShuffledSubjAnalysis_StrengthSequenceApproxPreserve.nstage;
        
        niter = opts.ShuffledSubjAnalysis_StrengthSequenceApproxPreserve.niter; 

        temp = opts.ShuffledSubjAnalysis_StrengthSequenceApproxPreserve.temp;
        
        [fcicis_shuffle_StrengthSequenceApproxPreserve, d, energymin, init_energy] = fcn_randomize_str_hb( ...
            fcicis, ...
            'nstage', nstage, ...
            'temp', temp, ...
            'niter', niter, ...
            'B0', fcicis_shuffle_DegreeSequencePreserve_hb,...
            'verbose', false);
        
        assert(isequal(d,fcicis_shuffle_DegreeSequencePreserve_hb));

        if is==1
        
            OUT.TmplFc_And_StrengthSequenceApproxPreserveShuffledSubjFc.nstage = nstage;
            
            OUT.TmplFc_And_StrengthSequenceApproxPreserveShuffledSubjFc.temp = temp;
            
            OUT.TmplFc_And_StrengthSequenceApproxPreserveShuffledSubjFc.energymin = zeros(1, ncic);
            
            OUT.TmplFc_And_StrengthSequenceApproxPreserveShuffledSubjFc.init_energy = zeros(1, ncic);
        end

        OUT.TmplFc_And_StrengthSequenceApproxPreserveShuffledSubjFc.energymin(is) = energymin;
        
        OUT.TmplFc_And_StrengthSequenceApproxPreserveShuffledSubjFc.init_energy(is) = init_energy;
    end
    
    regressors = opts.regressors;

    Do2norm = true;

    DoOrtho = true;
    
    setting = '00';

    %-determine weights for subject & template FC.
    %----------------------------------------------------------------------
    if ~isempty(opts.PrecomputedMixFC)

        OUT.TmplFc_And_SubjFc = opts.PrecomputedMixFC{ic}.TmplFc_And_SubjFc;
        
        OUT.TmplFc = opts.PrecomputedMixFC{ic}.TmplFc;
        
        OUT.SubjFc = opts.PrecomputedMixFC{ic}.SubjFc;

    else

        for ir=1:Nr

            I = Keep(:,ir);

            y = tpicis(I);

            d1 = fcicis;
            
            d2 = TmplFC_proc;
            
            [X, I_reg_v1] = getX(ir, I, d1, d2, regressors, setting, false, Do2norm, DoOrtho);
            
            mdl_v1 = fitlm(X, y); % fit with both template FC & subject FC
            
            d = OUT.TmplFc_And_SubjFc;
            
            OUT.TmplFc_And_SubjFc = fillstruct_step1(is, ir, I_reg_v1, zncicnr, mdl_v1, d);
            
            if DoTmplFc

                TMPL = struct;
                
                d = TmplFC_proc;
                
                [X, TMPL.I_reg] = getX_noSubjFc(ir, I, d, regressors, setting, false, Do2norm);
                
                TMPL.mdl = fitlm(X, y);
                
                d = OUT.TmplFc;
                
                OUT.TmplFc = fillstruct_step1(is,ir,TMPL.I_reg,zncicnr,TMPL.mdl,d);
            end

            if DoSubjFc
                
                SUBJ = struct;

                d = fcicis;
                
                [X, SUBJ.I_reg] = getX_noTmplFc(ir, I, d, regressors, setting, false, Do2norm);
                
                SUBJ.mdl = fitlm(X, y);
                
                d = OUT.SubjFc;
                
                OUT.SubjFc = fillstruct_step1(is,ir,SUBJ.I_reg,zncicnr,SUBJ.mdl,d);
            end

            if opts.ShuffledSubjAnalysis_DegreeSequencePreserve.do
                
                [X, I_reg_v1] = getX(ir, I, fcicis_shuffle_DegreeSequencePreserve_hb, TmplFC_proc, regressors, setting, false, Do2norm, DoOrtho);
                
                mdl_v1 = fitlm(X, y);
                
                d = OUT.TmplFc_And_DegreeSequencePreserveShuffledSubjFc;
                
                OUT.TmplFc_And_DegreeSequencePreserveShuffledSubjFc = fillstruct_step1(is, ir, I_reg_v1, zncicnr, mdl_v1, d);
            end

            if opts.ShuffledSubjAnalysis_StrengthSequenceApproxPreserve.do
                
                [X, I_reg_v1] = getX(ir,I,fcicis_shuffle_StrengthSequenceApproxPreserve, TmplFC_proc, regressors, setting, false, Do2norm, DoOrtho);
            
                mdl_v1 = fitlm(X, y);
                
                d = OUT.TmplFc_And_StrengthSequenceApproxPreserveShuffledSubjFc;
                
                OUT.TmplFc_And_StrengthSequenceApproxPreserveShuffledSubjFc = fillstruct_step1(is, ir, I_reg_v1, zncicnr, mdl_v1, d);
            end
        end
    end

    %-canonical PET regressors.
    %----------------------------------------------------------------------
    R0 = struct;

    R0.offtb = demean2norm(regressors.tau_offtarget.mean, false, Do2norm);
    
    R0.ontb  = demean2norm(regressors.tau_ontarget.mean, false, Do2norm);
    
    if opts.SubjectAmyPetAsRegressor.do
    
        R0.amypet = demean2norm(apicis, false, Do2norm);
    end

    %-FC regressors. 
    %----------------------------------------------------------------------
    R0.tmplfc = TmplFC_proc;

    R = getMixFcR(is, R0, fcicis, Nr, OUT.TmplFc_And_SubjFc);

    if opts.NetworkBasedFitlms.do
        
        atlasinfo = opts.NetworkBasedFitlms.atlasinfo;
        
        for intw=1:7
        
            I = struct;
            
            I.lh = find(atlasinfo.n_netwnum.lh==intw);
            
            I.rh = find(atlasinfo.n_netwnum.rh==intw) + atlasinfo.Nroi_hemi;

            % hybrid FC
            OUT.MixedWholeFc_yeo7{intw} = fillstruct_step2_yeo7(is, tpicis, R, OUT.MixedWholeFc_yeo7{intw}, I, 'mixfc');
            
            OUT.MixedWholeFc_yeo7_v2{intw} = fillstruct_step2_yeo7_v2(is, tpicis, R, OUT.MixedWholeFc_yeo7_v2{intw}, I, 'mixfc');

            % template FC
            OUT.TmplWholeFc_yeo7{intw} = fillstruct_step2_yeo7(is, tpicis ,R, OUT.TmplWholeFc_yeo7{intw}, I, 'tmplfc');
            
            OUT.TmplWholeFc_yeo7_v2{intw} = fillstruct_step2_yeo7_v2(is, tpicis, R, OUT.TmplWholeFc_yeo7_v2{intw}, I, 'tmplfc');

            % subject FC
            OUT.SubjWholeFc_yeo7{intw} = fillstruct_step2_yeo7(is, tpicis, R, OUT.SubjWholeFc_yeo7{intw}, I, 'subjfc');
            
            OUT.SubjWholeFc_yeo7_v2{intw} = fillstruct_step2_yeo7_v2(is, tpicis, R, OUT.SubjWholeFc_yeo7_v2{intw}, I, 'subjfc');
        end
    end

    %-no FC; canonical tau PET.
    %----------------------------------------------------------------------
    mdl = fitlm(R.ontb, tpicis);
    
    OUT.NoFc_ontb.r2(is) = mdl.Rsquared.Adjusted;
    

    mdl = fitlm(R.offtb, tpicis);
    
    OUT.NoFc_offtb.r2(is) = mdl.Rsquared.Adjusted;

    
    mdl = fitlm([R.offtb R.ontb], tpicis);
    
    OUT.NoFc_onofftb.r2(is)         = mdl.Rsquared.Adjusted;
    
    OUT.NoFc_onofftb.beta_offtb(is) = mdl.Coefficients.Estimate(2);
    
    OUT.NoFc_onofftb.beta_ontb(is)  = mdl.Coefficients.Estimate(3);
    
    %-model fits with no FC; individual amy PET.
    %----------------------------------------------------------------------
    if opts.SubjectAmyPetAsRegressor.do
        
        mdl = fitlm(R.amypet, tpicis);
        
        OUT.NoFc_amypet.r2(is) = mdl.Rsquared.Adjusted;

        mdl = fitlm([R.amypet R.ontb], tpicis);
        
        OUT.NoFc_amypet_and_ontb.r2(is) = mdl.Rsquared.Adjusted;
        
        OUT.NoFc_amypet_and_ontb.beta_amypet(is) = mdl.Coefficients.Estimate(2);
        
        OUT.NoFc_amypet_and_ontb.beta_ontb(is) = mdl.Coefficients.Estimate(3);

        mdl = fitlm([R.amypet R.offtb], tpicis);
        
        OUT.NoFc_amypet_and_offtb.r2(is) = mdl.Rsquared.Adjusted;
        
        OUT.NoFc_amypet_and_offtb.beta_amypet(is) = mdl.Coefficients.Estimate(2);
        
        OUT.NoFc_amypet_and_offtb.beta_offtb(is) = mdl.Coefficients.Estimate(3);

        mdl = fitlm([R.amypet R.ontb R.offtb], tpicis);
        
        OUT.NoFc_amypet_and_onofftb.r2(is) = mdl.Rsquared.Adjusted;
        
        OUT.NoFc_amypet_and_onofftb.beta_amypet(is) = mdl.Coefficients.Estimate(2);
        
        OUT.NoFc_amypet_and_onofftb.beta_ontb(is) = mdl.Coefficients.Estimate(3);
        
        OUT.NoFc_amypet_and_onofftb.beta_offtb(is) = mdl.Coefficients.Estimate(4);
    end

    %-model fits for subject FC.
    %----------------------------------------------------------------------
    [r2l, r2r] = fitlhrh(R.subjfc, tpicis);
    
    OUT.SubjWholeFc.lh.r2(is) = r2l;
    
    OUT.SubjWholeFc.rh.r2(is) = r2r;
    
    OUT.SubjWholeFc.lhrh.r2(is) = (r2l+r2r)/2;
    

    [r2l, r2r] = fitlhrh(R.subjfc, tpicis, R.ontb);
    
    OUT.SubjWholeFc_ontb.lh.r2(is) = r2l;
    
    OUT.SubjWholeFc_ontb.rh.r2(is) = r2r;
    
    OUT.SubjWholeFc_ontb.lhrh.r2(is) = (r2l+r2r)/2;
    

    [r2l, r2r] = fitlhrh(R.subjfc, tpicis, R.offtb);
    
    OUT.SubjWholeFc_offtb.lh.r2(is) = r2l;
    
    OUT.SubjWholeFc_offtb.rh.r2(is) = r2r;
    
    OUT.SubjWholeFc_offtb.lhrh.r2(is) = (r2l+r2r)/2;
    

    [r2l, r2r, mdl_lh, mdl_rh] = fitlhrh(R.subjfc, tpicis, R.offtb, R.ontb);

    OUT.SubjWholeFc_onofftb.lh.r2(is) = r2l;
    
    OUT.SubjWholeFc_onofftb.rh.r2(is) = r2r;
    
    OUT.SubjWholeFc_onofftb.lhrh.r2(is) = (r2l+r2r)/2;
    
    OUT.SubjWholeFc_onofftb.lh.beta_offtb(is) = mdl_lh.Coefficients.Estimate(2);
    
    OUT.SubjWholeFc_onofftb.lh.beta_ontb(is) = mdl_lh.Coefficients.Estimate(3);
    
    OUT.SubjWholeFc_onofftb.lh.betas(is,:) = mdl_lh.Coefficients.Estimate(4:end);
    
    OUT.SubjWholeFc_onofftb.rh.beta_offtb(is) = mdl_rh.Coefficients.Estimate(2);
    
    OUT.SubjWholeFc_onofftb.rh.beta_ontb(is) = mdl_rh.Coefficients.Estimate(3);
    
    OUT.SubjWholeFc_onofftb.rh.betas(is,:) = mdl_rh.Coefficients.Estimate(4:end);
    
    %-model fits for template FC.
    %----------------------------------------------------------------------
    [r2l, r2r] = fitlhrh(R.tmplfc, tpicis);

    OUT.TmplWholeFc.lh.r2(is) = r2l;
    
    OUT.TmplWholeFc.rh.r2(is) = r2r;
    
    OUT.TmplWholeFc.lhrh.r2(is) = (r2l+r2r)/2;
    

    [r2l, r2r] = fitlhrh(R.tmplfc, tpicis, R.ontb);
    
    OUT.TmplWholeFc_ontb.lh.r2(is) = r2l;
    
    OUT.TmplWholeFc_ontb.rh.r2(is)  = r2r;
    
    OUT.TmplWholeFc_ontb.lhrh.r2(is) = (r2l+r2r)/2;
    
  
    [r2l, r2r] = fitlhrh(R.tmplfc, tpicis, R.offtb);
    
    OUT.TmplWholeFc_offtb.lh.r2(is) = r2l;
    
    OUT.TmplWholeFc_offtb.rh.r2(is) = r2r;
    
    OUT.TmplWholeFc_offtb.lhrh.r2(is) = (r2l+r2r)/2;
    

    [r2l, r2r, mdl_lh, mdl_rh] = fitlhrh(R.tmplfc, tpicis, R.offtb, R.ontb);
    
    OUT.TmplWholeFc_onofftb.lh.r2(is) = r2l;
    
    OUT.TmplWholeFc_onofftb.rh.r2(is) = r2r;
    
    OUT.TmplWholeFc_onofftb.lhrh.r2(is) = (r2l+r2r)/2;
    
    OUT.TmplWholeFc_onofftb.lh.beta_offtb(is) = mdl_lh.Coefficients.Estimate(2);
    
    OUT.TmplWholeFc_onofftb.lh.beta_ontb(is) = mdl_lh.Coefficients.Estimate(3);
    
    OUT.TmplWholeFc_onofftb.lh.betas(is,:) = mdl_lh.Coefficients.Estimate(4:end);
    
    OUT.TmplWholeFc_onofftb.rh.beta_offtb(is) = mdl_rh.Coefficients.Estimate(2);
    
    OUT.TmplWholeFc_onofftb.rh.beta_ontb(is) = mdl_rh.Coefficients.Estimate(3);
    
    OUT.TmplWholeFc_onofftb.rh.betas(is,:) = mdl_rh.Coefficients.Estimate(4:end);
    
    %-model fits for hybrid FC.
    %----------------------------------------------------------------------
    OUT.MixedWholeFc = fillstruct_step2(is, tpicis, R, OUT.MixedWholeFc);

    [r2l, r2r] = fitlhrh(R.mixfc, tpicis, R.ontb);
    
    OUT.MixedWholeFc_ontb.lh.r2(is) = r2l;
   
    OUT.MixedWholeFc_ontb.rh.r2(is) = r2r;
    
    OUT.MixedWholeFc_ontb.lhrh.r2(is) = (r2l+r2r)/2;
    
    
    [r2l, r2r] = fitlhrh(R.mixfc, tpicis, R.offtb);
    
    OUT.MixedWholeFc_offtb.lh.r2(is) = r2l;
    
    OUT.MixedWholeFc_offtb.rh.r2(is) = r2r;
    
    OUT.MixedWholeFc_offtb.lhrh.r2(is) = (r2l+r2r)/2;
    
    
    [r2l, r2r, mdl_lh, mdl_rh] = fitlhrh(R.mixfc, tpicis, R.offtb, R.ontb);
    
    OUT.MixedWholeFc_onofftb.lh.r2(is) = r2l;
    
    OUT.MixedWholeFc_onofftb.rh.r2(is) = r2r;
    
    OUT.MixedWholeFc_onofftb.lhrh.r2(is) = (r2l+r2r)/2;
    
    OUT.MixedWholeFc_onofftb.lh.beta_offtb(is) = mdl_lh.Coefficients.Estimate(2);
    
    OUT.MixedWholeFc_onofftb.lh.beta_ontb(is)  = mdl_lh.Coefficients.Estimate(3);
    
    OUT.MixedWholeFc_onofftb.lh.betas(is,:) = mdl_lh.Coefficients.Estimate(4:end);
    
    OUT.MixedWholeFc_onofftb.rh.beta_offtb(is) = mdl_rh.Coefficients.Estimate(2);
    
    OUT.MixedWholeFc_onofftb.rh.beta_ontb(is) = mdl_rh.Coefficients.Estimate(3);
    
    OUT.MixedWholeFc_onofftb.rh.betas(is,:) = mdl_rh.Coefficients.Estimate(4:end);
    
    if opts.SubjectAmyPetAsRegressor.do

        %-model fits for hybrid FC + amypet.
        %------------------------------------------------------------------
        [r2l, r2r] = fitlhrh(R.mixfc, tpicis, R.amypet);
        
        OUT.MixedWholeFc_amypet.lh.r2(is) = r2l;
        
        OUT.MixedWholeFc_amypet.rh.r2(is) = r2r;
        
        OUT.MixedWholeFc_amypet.lhrh.r2(is) = (r2l+r2r)/2;

        %-model fits for hybrid FC + amypet + ontb.
        %------------------------------------------------------------------
        [r2l, r2r] = fitlhrh(R.mixfc, tpicis, R.amypet, R.ontb);
        
        OUT.MixedWholeFc_amypet_and_ontb.lh.r2(is) = r2l;
        
        OUT.MixedWholeFc_amypet_and_ontb.rh.r2(is) = r2r;
        
        OUT.MixedWholeFc_amypet_and_ontb.lhrh.r2(is) = (r2l+r2r)/2;
        
        %-model fits for hybrid FC + amypet + offtb.
        %------------------------------------------------------------------
        [r2l, r2r] = fitlhrh(R.mixfc, tpicis, R.amypet, R.offtb);
        
        OUT.MixedWholeFc_amypet_and_offtb.lh.r2(is) = r2l;
        
        OUT.MixedWholeFc_amypet_and_offtb.rh.r2(is) = r2r;
        
        OUT.MixedWholeFc_amypet_and_offtb.lhrh.r2(is) = (r2l+r2r)/2;

        %-model fits for hybrid FC + amypet + ontb + offtb.
        %------------------------------------------------------------------
        [r2l, r2r] = fitlhrh(R.mixfc, tpicis, R.amypet, R.ontb, R.offtb);
        
        OUT.MixedWholeFc_amypet_and_onofftb.lh.r2(is) = r2l;
        
        OUT.MixedWholeFc_amypet_and_onofftb.rh.r2(is) = r2r;
        
        OUT.MixedWholeFc_amypet_and_onofftb.lhrh.r2(is) = (r2l+r2r)/2;

        OUT.MixedWholeFc_amypet_and_onofftb.lh.beta_amypet(is) = mdl_lh.Coefficients.Estimate(2);
        
        OUT.MixedWholeFc_amypet_and_onofftb.lh.beta_ontb(is) = mdl_lh.Coefficients.Estimate(3);
        
        OUT.MixedWholeFc_amypet_and_onofftb.lh.beta_offtb(is) = mdl_lh.Coefficients.Estimate(4);
        
        OUT.MixedWholeFc_amypet_and_onofftb.lh.betas(is,:) = mdl_lh.Coefficients.Estimate(5:end);

        OUT.MixedWholeFc_amypet_and_onofftb.rh.beta_amypet(is) = mdl_rh.Coefficients.Estimate(2);
        
        OUT.MixedWholeFc_amypet_and_onofftb.rh.beta_ontb(is) = mdl_rh.Coefficients.Estimate(3);
        
        OUT.MixedWholeFc_amypet_and_onofftb.rh.beta_offtb(is) = mdl_rh.Coefficients.Estimate(4);
        
        OUT.MixedWholeFc_amypet_and_onofftb.rh.betas(is,:) = mdl_rh.Coefficients.Estimate(5:end);
    end
end
end

%==========================================================================
function OUT = initFitlms(ncic, Nr, opts)
Nr_hemi = floor(Nr/2);

ddd1 = zeros(ncic, 1);

ddd2 = zeros(ncic, Nr_hemi);

S1 = struct;
S1.r2 = ddd1;

S2 = struct;
S2.r2         = ddd1;
S2.beta_ontb  = ddd1;
S2.beta_offtb = ddd1;

S3 = struct;
S3.lh.r2   = ddd1;
S3.rh.r2   = ddd1;
S3.lhrh.r2 = ddd1;

S4 = struct;
S4.lh.r2         = ddd1;
S4.rh.r2         = ddd1;
S4.lhrh.r2       = ddd1;
S4.lh.betas      = ddd2;
S4.rh.betas      = ddd2;
S4_v2 = S4;
S4_v2.lh.beta_ontb  = ddd1;
S4_v2.lh.beta_offtb = ddd1;
S4_v2.rh.beta_ontb  = ddd1;
S4_v2.rh.beta_offtb = ddd1;

OUT = struct;
OUT.NoFc_ontb    = S1;
OUT.NoFc_offtb   = S1;
OUT.NoFc_onofftb = S2;

if opts.SubjectAmyPetAsRegressor.do
    
    % just amy
    d = struct;
    d.r2 = ddd1; 
    OUT.NoFc_amypet = d;
    
    % amy + ontb
    d = struct;
    d.r2          = ddd1;
    d.beta_amypet = ddd1;
    d.beta_ontb   = ddd1;
    OUT.NoFc_amypet_and_ontb = d;

    % amy + offtb
    d = struct;
    d.r2          = ddd1;
    d.beta_amypet = ddd1;
    d.beta_offtb  = ddd1;
    OUT.NoFc_amypet_and_offtb = d;
    
    % amy + ontb + offtb
    d = struct;
    d.r2          = ddd1;
    d.beta_amypet = ddd1;
    d.beta_ontb   = ddd1;
    d.beta_offtb  = ddd1;
    OUT.NoFc_amypet_and_onofftb = d;
end

OUT.TmplFc.r2        = zeros(ncic, Nr);
OUT.TmplFc.beta_tmpl = zeros(ncic, Nr);
OUT.TmplFc.pVal_tmpl = zeros(ncic, Nr);

OUT.SubjFc.r2        = zeros(ncic, Nr);
OUT.SubjFc.beta_subj = zeros(ncic, Nr);
OUT.SubjFc.pVal_subj = zeros(ncic, Nr);

OUT.TmplFc_And_SubjFc.r2        = zeros(ncic, Nr);
OUT.TmplFc_And_SubjFc.beta_tmpl = zeros(ncic, Nr);
OUT.TmplFc_And_SubjFc.beta_subj = zeros(ncic, Nr);
OUT.TmplFc_And_SubjFc.pVal_tmpl = zeros(ncic, Nr);

OUT.TmplFc_And_SubjFc.pVal_subj = zeros(ncic, Nr);

OUT.SubjWholeFc          = S3;
OUT.SubjWholeFc_ontb     = S3;
OUT.SubjWholeFc_offtb    = S3;
OUT.SubjWholeFc_onofftb  = S4_v2;

OUT.TmplWholeFc          = S3;
OUT.TmplWholeFc_ontb     = S3;
OUT.TmplWholeFc_offtb    = S3;
OUT.TmplWholeFc_onofftb  = S4_v2;

OUT.MixedWholeFc         = S4;
OUT.MixedWholeFc_ontb    = S3;
OUT.MixedWholeFc_offtb   = S3;
OUT.MixedWholeFc_onofftb = S4_v2;

if opts.ShuffledSubjAnalysis_DegreeSequencePreserve.do
    OUT.TmplFc_And_DegreeSequencePreserveShuffledSubjFc = OUT.TmplFc_And_SubjFc;
end

if opts.ShuffledSubjAnalysis_StrengthSequenceApproxPreserve.do
    OUT.TmplFc_And_StrengthSequenceApproxPreserveShuffledSubjFc = OUT.TmplFc_And_SubjFc;
end

if opts.NetworkBasedFitlms.do
    atlasinfo = opts.NetworkBasedFitlms.atlasinfo;

    netwnum_lh = atlasinfo.n_netwnum.lh;
    netwnum_rh = atlasinfo.n_netwnum.rh;

    v2_descrip = 'a single network-based lm fit using both lh & rh';
    % i.e. not one model per hemisphere and then averaging the r2
    
    for intw=1:7

        Nlh = nnz(netwnum_lh==intw);
        Nrh = nnz(netwnum_rh==intw);

        Zlh = zeros(ncic,Nlh);
        Zrh = zeros(ncic,Nrh);

        % subjfc
        OUT.SubjWholeFc_yeo7{intw} = S3;

        % tmplfc
        OUT.TmplWholeFc_yeo7{intw} = S3;

        % mixfc
        OUT.MixedWholeFc_yeo7{intw} = S3;
        OUT.MixedWholeFc_yeo7{intw}.lh.betas = Zlh;
        OUT.MixedWholeFc_yeo7{intw}.rh.betas = Zrh;
        
        % subjfc v2
        OUT.SubjWholeFc_yeo7_v2{intw}.description  = v2_descrip;
        OUT.SubjWholeFc_yeo7_v2{intw}.lhrh.r2      = ddd1;
        OUT.SubjWholeFc_yeo7_v2{intw}.lh.betas     = Zlh;
        OUT.SubjWholeFc_yeo7_v2{intw}.rh.betas     = Zrh;

        % tmplfc v2
        OUT.TmplWholeFc_yeo7_v2{intw}.description  = v2_descrip;
        OUT.TmplWholeFc_yeo7_v2{intw}.lhrh.r2      = ddd1;
        OUT.TmplWholeFc_yeo7_v2{intw}.lh.betas     = Zlh;
        OUT.TmplWholeFc_yeo7_v2{intw}.rh.betas     = Zrh;

        % hybridfc v2
        OUT.MixedWholeFc_yeo7_v2{intw}.description = v2_descrip;
        OUT.MixedWholeFc_yeo7_v2{intw}.lhrh.r2     = ddd1;
        OUT.MixedWholeFc_yeo7_v2{intw}.lh.betas    = Zlh;
        OUT.MixedWholeFc_yeo7_v2{intw}.rh.betas    = Zrh;
    end
end
end

%==========================================================================
function [X, I_reg] = getregmatrixetc(setting, R)
switch setting
    case '00'
        X = [R.tmpl R.subj];
        I_offtb = [];
        I_ontb  = [];
    case '10'
        X = [R.tmpl R.subj R.offtb];
        I_offtb = 4;
        I_ontb  = [];
    case '01'
        X = [R.tmpl R.subj R.ontb];
        I_offtb = [];
        I_ontb  = 4;
    case '11'
        X = [R.tmpl R.subj R.offtb R.ontb];
        I_offtb = 4;
        I_ontb  = 5;
    otherwise
        error('extend');
end
I_reg = struct;
I_reg.tmpl  = 2;
I_reg.subj  = 3;
I_reg.ontb  = I_ontb;
I_reg.offtb = I_offtb;
end

%==========================================================================
function [X, I_reg] = getregmatrixetc_noTmplFc(setting, R)
switch setting
    case '00'
        X = [R.subj];
        I_offtb = [];
        I_ontb  = [];
    case '10'
        X = [R.subj R.offtb];
        I_offtb = 3;
        I_ontb  = [];
    case '01'
        X = [R.subj R.ontb];
        I_offtb = [];
        I_ontb  = 3;
    case '11'
        X = [R.subj R.offtb R.ontb];
        I_offtb = 3;
        I_ontb  = 4;
    otherwise
        error('extend');
end
I_reg = struct;
I_reg.subj  = 2;
I_reg.ontb  = I_ontb;
I_reg.offtb = I_offtb;
end

%==========================================================================
function [X, I_reg] = getregmatrixetc_noSubjFc(setting, R)
switch setting
    case '00'
        X = [R.tmpl];
        I_offtb = [];
        I_ontb  = [];
    case '10'
        X = [R.tmpl R.offtb];
        I_offtb = 3;
        I_ontb  = [];
    case '01'
        X = [R.tmpl R.ontb];
        I_offtb = [];
        I_ontb  = 3;
    case '11'
        X = [R.tmpl R.offtb R.ontb];
        I_offtb = 3;
        I_ontb  = 4;
    otherwise
        error('extend');
end
I_reg = struct;
I_reg.tmpl  = 2;
I_reg.ontb  = I_ontb;
I_reg.offtb = I_offtb;
end

%==========================================================================
function R = getRonoffavg(regressors, I, DoDemean, Do2norm, ir)
R = struct;
R.offtb  = demean2norm(regressors.tau_offtarget.mean(I), DoDemean, Do2norm, ir);
R.ontb   = demean2norm(regressors.tau_ontarget.mean(I), DoDemean, Do2norm, ir);
end

%==========================================================================
function [X, I_reg] = getX(ir, I, SubjFC, TmplFC, regressors, setting, DoDemean, Do2norm, DoOrtho)
R = getRonoffavg(regressors, I, DoDemean, Do2norm, ir);
R.tmpl = demean2norm(TmplFC(I, ir), DoDemean, Do2norm, ir);
if DoOrtho
    d = SubjFC(I, ir);
    d = hb_orth(d, R.tmpl);
    R.subj = demean2norm(d, DoDemean, Do2norm, ir);
else
    R.subj = demean2norm(SubjFC(I, ir), DoDemean, Do2norm, ir);
end
[X, I_reg] = getregmatrixetc(setting, R);
end

%==========================================================================
function [X, I_reg] = getX_noTmplFc(ir, I, SubjFC, regressors, setting, DoDemean, Do2norm)
R = getRonoffavg(regressors, I, DoDemean, Do2norm, ir);
R.subj = demean2norm(SubjFC(I, ir), DoDemean, Do2norm, ir);
[X, I_reg] = getregmatrixetc_noTmplFc(setting, R);
end

%==========================================================================
function [X, I_reg] = getX_noSubjFc(ir, I, TmplFC, regressors, setting, DoDemean, Do2norm)
R = getRonoffavg(regressors, I, DoDemean, Do2norm, ir);
R.tmpl = demean2norm(TmplFC(I, ir), DoDemean, Do2norm, ir);
[X, I_reg] = getregmatrixetc_noSubjFc(setting, R);
end

%==========================================================================
function R = getMixFcR(is, R, subjfc, Nr, Y)
R.subjfc = subjfc;
%--enforce unit norms.
% for subj & tmpl FC columns; important as otherwise problem with:
% (1) the mixing
% (2) interpreting the effect sizes after model fits
R.tmplfc = R.tmplfc./vecnorm(R.tmplfc);
R.subjfc = R.subjfc./vecnorm(R.subjfc);
%--mix.
bt = Y.beta_tmpl(is,:);
bs = Y.beta_subj(is,:);
bt = repmat(bt, Nr, 1);
bs = repmat(bs, Nr, 1);
R.mixfc  = bt.*R.tmplfc + bs.*R.subjfc;
%--enforce unit norms.
% reason (2) as above
R.mixfc = R.mixfc./vecnorm(R.mixfc);
end

%==========================================================================
function Y = fillstruct_step1(is,ir,I_reg,Z,mdl,Y)
Initialize = and(is==1,ir==1);
if iscell(mdl)
    N_mdl = length(mdl);
    assert(length(I_reg)==N_mdl);
else
    mdl   = {mdl};
    I_reg = {I_reg};
    N_mdl = 1;
end
for k=1:N_mdl
    if k==N_mdl
        M = N_mdl; % averaging in last round
    else
        M = 1;
    end
    Y.r2(is,ir) = (Y.r2(is,ir) + mdl{k}.Rsquared.Adjusted) /M;
    if isfield(I_reg{k}, 'tmpl')
        Y.beta_tmpl(is,ir) = (Y.beta_tmpl(is,ir) + mdl{k}.Coefficients.Estimate(I_reg{k}.tmpl)) /M;
        Y.pVal_tmpl(is,ir) = (Y.pVal_tmpl(is,ir) + mdl{k}.Coefficients.pValue(I_reg{k}.tmpl)) /M;
    end
    if isfield(I_reg{k}, 'subj')
        Y.beta_subj(is,ir) = (Y.beta_subj(is,ir) + mdl{k}.Coefficients.Estimate(I_reg{k}.subj)) /M;
        Y.pVal_subj(is,ir) = (Y.pVal_subj(is,ir) + mdl{k}.Coefficients.pValue(I_reg{k}.subj)) /M;
    end
    if not(isempty(I_reg{k}.offtb))
        if Initialize
            Y.beta_offtb = Z;
            Y.pVal_offtb = Z;
        end
        Y.beta_offtb(is,ir) = (Y.beta_offtb(is,ir) + mdl{k}.Coefficients.Estimate(I_reg{k}.offtb)) /M;
        Y.pVal_offtb(is,ir) = (Y.pVal_offtb(is,ir) + mdl{k}.Coefficients.pValue(I_reg{k}.offtb)) /M;
    end
    if not(isempty(I_reg{k}.ontb))
        if Initialize
            Y.beta_ontb = Z;
            Y.pVal_ontb = Z;
        end
        Y.beta_ontb(is,ir) = (Y.beta_ontb(is,ir) + mdl{k}.Coefficients.Estimate(I_reg{k}.ontb)) /M;
        Y.pVal_ontb(is,ir) = (Y.pVal_ontb(is,ir) + mdl{k}.Coefficients.pValue(I_reg{k}.ontb)) /M;
    end
end
end

%==========================================================================
function Y = fillstruct_step2_yeo7_v2(is, tpicis, R, Y, I_netw, WhichFc)
Nlh = length(I_netw.lh);
Rntw_lh = R.(WhichFc)(:,I_netw.lh);
Rntw_rh = R.(WhichFc)(:,I_netw.rh);
XX_lhrh = [Rntw_lh, Rntw_rh];
mdl_lhrh = fitlm(XX_lhrh, tpicis);
Y.lhrh.r2(is)    = mdl_lhrh.Rsquared.Adjusted;
Y.lh.betas(is,:) = mdl_lhrh.Coefficients.Estimate(2:(2+Nlh-1));
Y.rh.betas(is,:) = mdl_lhrh.Coefficients.Estimate((2+Nlh):end);
end

%==========================================================================
function Y = fillstruct_step2_yeo7(is, tpicis, R, Y, I_netw, WhichFc)
Rntw = struct;
Rntw.lh = R.(WhichFc)(:,I_netw.lh);
Rntw.rh = R.(WhichFc)(:,I_netw.rh);
[r2l, r2r, mdl_lh, mdl_rh] = fitlhrh(Rntw, tpicis);
Y.lh.r2(is) = r2l;
Y.rh.r2(is) = r2r;
Y.lhrh.r2(is) = (r2l+r2r)/2;
switch WhichFc
    case 'mixfc'
        Y.lh.betas(is,:) = mdl_lh.Coefficients.Estimate(2:end);
        Y.rh.betas(is,:) = mdl_rh.Coefficients.Estimate(2:end);
    case {'tmplfc', 'subjfc'}
        % n/a
end
end

%==========================================================================
function Y = fillstruct_step2(is, tpicis, R, Y)
[r2l, r2r, mdl_lh, mdl_rh] = fitlhrh(R.mixfc, tpicis);
Y.lh.r2(is)      = r2l;
Y.rh.r2(is)      = r2r;
Y.lhrh.r2(is)    = (r2l+r2r)/2;
Y.lh.betas(is,:) = mdl_lh.Coefficients.Estimate(2:end);
Y.rh.betas(is,:) = mdl_rh.Coefficients.Estimate(2:end);
end

