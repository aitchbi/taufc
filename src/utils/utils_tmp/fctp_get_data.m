function [FCs, PETs, sess_pet, sess_rs, INFO] = fctp_get_data(f_results, IDs, INFO, IDs_base, DiagTypes, PathologySplit, WhichPet, varargin)

funcLogi = @(x) assert(islogical(x));

funcStruct = @(x) assert(isstruct(x));

p = inputParser;

addParameter(p,'SkipSubjectsWithNans', true, funcLogi);

addParameter(p,'InclusionCriteria', [], funcStruct);

parse(p,varargin{:});

opts = p.Results;

if isempty(opts.InclusionCriteria)

    opts.InclusionCriteria.Young_CU_AmyloidNeg_Class = false;
end

%-prepare.
%--------------------------------------------------------------------------
d = load(f_results);

switch WhichPet

    case 'Tau'
    
        DATA = d.TPD;
    
    case 'Amy'
    
        DATA = d.APD;
end

assert(size(DATA.FC,3)==length(IDs_base));

d = ismember(IDs_base(DATA.I_exist), IDs.all);

I_exist_allgood = DATA.I_exist(d);

IDs_allgood = IDs_base(I_exist_allgood);

N_allgood = length(IDs_allgood);

assert(nnz(I_exist_allgood)==N_allgood);

assert(max(I_exist_allgood)<=length(IDs_base));

msg = 'Total number of done&exclusion-criteria-applied subjects';

fprintf('\n.%s: %d\n', msg, N_allgood);

A = IDs_allgood;

B = I_exist_allgood;

INFO = prunestruct(INFO, ismember(IDs.all, A));

%-split FCs & TPs to subclasses.
%--------------------------------------------------------------------------
FCs = struct;

FCs.all = DATA.FC(:,:,B);

FCs.all_N = size(FCs.all,3);

PETs = struct;

PETs.all = DATA.pet(:,B);

assert(FCs.all_N == size(PETs.all,2));

if PathologySplit.do

    for k=1:length(DiagTypes)
    
        dtype = DiagTypes{k};


        a = getinds(IDs.(dtype).all, A, B);
        
        PETs.(dtype).all = DATA.pet(:, a);
        
        FCs.(dtype).all = DATA.FC(:,:,a);
        
        FCs.(dtype).all_inds1365 = a;
        
        FCs.(dtype).all_N = length(a);

        
        a = getinds(IDs.(dtype).ab0, A, B);
        
        PETs.(dtype).ab0 = DATA.pet(:,   a);
        
        FCs.(dtype).ab0 = DATA.FC(:,:, a);
        
        FCs.(dtype).ab0_inds1365 = a;
        
        FCs.(dtype).ab0_N = length(a);
        

        a = getinds(IDs.(dtype).ab1, A, B);

        PETs.(dtype).ab1 = DATA.pet(:,   a);
        
        FCs.(dtype).ab1 = DATA.FC(:,:, a);
        
        FCs.(dtype).ab1_inds1365 = a;
        
        FCs.(dtype).ab1_N = length(a);
        

        if isequal(dtype, 'Normal')

            if opts.InclusionCriteria.Young_CU_AmyloidNeg_Class
            
                a = getinds(IDs.(dtype).ab0_young, A, B);
                
                PETs.(dtype).ab0_young = DATA.pet(:,   a);
                
                FCs.(dtype).ab0_young = DATA.FC(:,:, a);
                
                FCs.(dtype).ab0_young_inds1365 = a;
                
                FCs.(dtype).ab0_young_N = length(a);
            end
        end

        assert1(FCs, dtype);
        
        if strcmp(PathologySplit.which, 'amyloid-&-tau')
        
            a = getinds(IDs.(dtype).ab1_tau0, A, B);
            
            PETs.(dtype).ab1_tau0 = DATA.pet(:,a);
            
            FCs.(dtype).ab1_tau0 = DATA.FC(:,:,a);
            
            FCs.(dtype).ab1_tau0_inds1365 = a;
            
            FCs.(dtype).ab1_tau0_N = length(a);
            

            a = getinds(IDs.(dtype).ab1_tau1, A, B);
            
            PETs.(dtype).ab1_tau1 = DATA.pet(:,a);
            
            FCs.(dtype).ab1_tau1 = DATA.FC(:,:,a);
            
            FCs.(dtype).ab1_tau1_inds1365 = a;
            
            FCs.(dtype).ab1_tau1_N = length(a);
            
            assert2(FCs, dtype);
        end
    end
end
sess_pet = DATA.sess_pet(I_exist_allgood);

sess_rs = DATA.sess_rs(I_exist_allgood);

%-drop NaNs.
%--------------------------------------------------------------------------
if opts.SkipSubjectsWithNans

    N0 = FCs.all_N;
    
    [FCs, PETs, sess_pet, sess_rs, INFO] = dropnans(FCs, PETs, sess_pet, sess_rs, INFO, DiagTypes, PathologySplit);
    
    fprintf('\n.Initial number of subjects: %d.\n', N0);
    
    fprintf('\n.Remaining after NaN excluions: %d.\n', FCs.all_N);
end
end

%==========================================================================
function [I, Id] = getinds(IDs,A,B)

d = ismember(A,IDs);

I = B(d);

Id = find(d);
end

%==========================================================================
function [FCs, PETs, sess_pet, sess_rs, INFO] = dropnans(FCs, PETs, sess_pet, sess_rs, INFO, DiagTypes, PathologySplit)

N = size(PETs.all,2);

if any(isnan(PETs.all(:)))
    
    I_nan_tp = [];
    
    for iS=1:N
    
        d = PETs.all(:,iS);
        
        if any(isnan(d(:)))
        
            I_nan_tp = [I_nan_tp, iS]; %#ok<*AGROW> 
        end
    end
    
    fprintf('\n.%d/%d subjects skipped due to NaN in their TP.\n', length(I_nan_tp), N);

else
    
    I_nan_tp = [];
end

if any(isnan(FCs.all(:)))

    I_nan_fc = [];
    
    for iS=1:N
    
        d = FCs.all(:,:,iS);
        
        if any(isnan(d(:)))
        
            I_nan_fc = [I_nan_fc, iS];
        end
    end
  
    fprintf('\n.%d/%d subjects have NaN in their FC.\n', length(I_nan_fc), N);

else

    I_nan_fc = [];
end

I_nan = union(I_nan_tp, I_nan_fc);

FCs.all(:,:,I_nan) = [];

FCs.all_N = size(FCs.all,3);

PETs.all(:,I_nan) = [];

sess_pet(I_nan) = [];

sess_rs(I_nan) = [];

I_keep = true(N,1);

I_keep(I_nan) = 0;

INFO = prunestruct(INFO, I_keep);

if PathologySplit.do

    for k=1:length(DiagTypes)

        dtype = DiagTypes{k};

        
        a = ismember(FCs.(dtype).all_inds1365, I_nan);
    
        PETs.(dtype).all(:,a) = [];
        
        FCs.(dtype).all(:,:,a) = [];
        
        FCs.(dtype).all_inds1365(a) = [];
        
        FCs.(dtype).all_N = FCs.(dtype).all_N - nnz(a);
        
        assert(size(FCs.(dtype).all,3)==FCs.(dtype).all_N);


        a = ismember(FCs.(dtype).ab0_inds1365, I_nan);
        
        PETs.(dtype).ab0(:,a) = [];
        
        FCs.(dtype).ab0(:,:,a) = [];
        
        FCs.(dtype).ab0_inds1365(a) = [];
        
        FCs.(dtype).ab0_N = FCs.(dtype).ab0_N - nnz(a);


        a = ismember(FCs.(dtype).ab1_inds1365, I_nan);
        
        PETs.(dtype).ab1(:,a) = [];
        
        FCs.(dtype).ab1(:,:,a) = [];
        
        FCs.(dtype).ab1_inds1365(a) = [];
        
        FCs.(dtype).ab1_N = FCs.(dtype).ab1_N - nnz(a);

        if isfield(FCs.(dtype), 'ab0_young')
            
            a = ismember(FCs.(dtype).ab0_young_inds1365, I_nan);
            
            PETs.(dtype).ab0_young(:,a) = [];
            
            FCs.(dtype).ab0_young(:,:,a) = [];
            
            FCs.(dtype).ab0_young_inds1365(a) = [];
            
            FCs.(dtype).ab0_young_N = FCs.(dtype).ab0_young_N - nnz(a);
        end

        assert1(FCs, dtype);
    end
end
end

%==========================================================================
function assert1(FCs,d)

d1 = union(FCs.(d).ab0_inds1365, FCs.(d).ab1_inds1365);

if isfield(FCs.(d), 'ab0_young')

    d1 = union(d1, FCs.(d).ab0_young_inds1365);
end

d2 = FCs.(d).all_inds1365;

assert(isequal(d1, d2));

assert(all(ismember(d2, 1:1365)));

d1 = FCs.(d).ab0_N + FCs.(d).ab1_N;

if isfield(FCs.(d), 'ab0_young')

    d1 = d1 + FCs.(d).ab0_young_N;
end

d2 = FCs.(d).all_N;

assert(isequal(d1, d2));
end

%==========================================================================
function assert2(FCs,d)

d1 = union(FCs.(d).ab1_tau0_inds1365, FCs.(d).ab1_tau1_inds1365);

d2 = FCs.(d).ab1_inds1365;

assert(isequal(d1, d2));

assert(all(ismember(d2, 1:1365)));

d1 = FCs.(d).ab1_tau0_N + FCs.(d).ab1_tau1_N;

d2 = FCs.(d).ab1_N;

assert(isequal(d1, d2));
end