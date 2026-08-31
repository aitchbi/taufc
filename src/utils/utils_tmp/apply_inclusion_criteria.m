function [I_keep, N_exclude] = apply_inclusion_criteria(opts)    

age = opts.data.age;

rsqa = opts.data.rsqa;

thresh_rsqa_meanFD = opts.thresh_rsqa_meanFD;

thresh_rsqa_maxFD  = opts.thresh_rsqa_maxFD;

Ns = length(age);

switch  opts.age

    case {'above-20', 'above-40', 'above-50', 'above-55', 'above-60'}
    
        th_age = str2double(opts.age(7:8));
        
        I1 = age(:)>=th_age;
end

switch opts.rsqa
    
    case 'none'
    
        I2 = true(Ns,1);
    
    case 'mean-max-FD'
    
        a = rsqa.meanFD<=thresh_rsqa_meanFD;
        
        b = rsqa.maxFD<=thresh_rsqa_maxFD;
        
        I2  = and(a(:), b(:));
end

I_keep = and(I1, I2);

N_exclude.N_Young_CU_AmyloidNeg_Class = [];

N_exclude.all_classes = Ns - nnz(I_keep);

N_exclude.age = Ns - nnz(I1);

N_exclude.rsqa = Ns - nnz(I2);

N_exclude.age_and_rsqa = nnz(and(not(I1),not(I2)));
end
