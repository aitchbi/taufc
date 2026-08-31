function [FC_class, TP_class, INFO_class, sess_pet_class, sess_rs_class, N_class, lbls, Nc] = fctp_get_classes(FCs, TPs, INFO_v0, sess_pet_v0, sess_rs_v0, Ns, I_map_kept_to_1365, PathologySplit)
         
assert(PathologySplit.do);

assert(strcmp(PathologySplit.which, 'amyloid'))

Nc = 7;

FC_class = cell(Nc,1);

TP_class = cell(Nc,1);

INFO_class = cell(Nc,1);

sess_pet_class = cell(Nc,1);

sess_rs_class  = cell(Nc,1);

N_class = zeros(Nc,1);

tag1 = {
    'Normal'
    'SCD'
    'MCI'
    'Normal'
    'SCD'
    'MCI'
    'AD'
    };

tag2 = {
    'ab0'
    'ab0'
    'ab0'
    'ab1'
    'ab1'
    'ab1'
    'ab1'
    };

tag2_v2 = {
    'A-'
    'A-'
    'A-'
    'A+'
    'A+'
    'A+'
    'A+'
    };

lbls = cell(Nc,1);

for ic=1:Nc

    lbls{ic} = [tag1{ic}, ' ', tag2_v2{ic}];
end

% build
for ic=1:Nc
    
    FC_class{ic} = FCs.(tag1{ic}).(tag2{ic});
    
    TP_class{ic} = TPs.(tag1{ic}).(tag2{ic});
    
    N_class(ic) = size(TP_class{ic},2);
    
    d = FCs.(tag1{ic}).([tag2{ic},'_inds1365']);
    
    d = map_ind1365_to_xxxx(d, I_map_kept_to_1365, Ns.all);
    
    assert(nnz(d)==N_class(ic));
    
    INFO_class{ic}     = prunestruct(INFO_v0, d);
    
    sess_pet_class{ic} = sess_pet_v0(d);
    
    sess_rs_class{ic}  = sess_rs_v0(d);
end

% verify
for ic=1:Nc
    
    d = INFO_class{ic}.diagnosis;
    
    d = cellfun(@(x) isequal(x, tag1{ic}), d);
    
    assert(all(d), 'fishy classing');
end

% drop subjs with NaNs
N0 = N_class;

[FC_class, TP_class, INFO_class, sess_pet_class, sess_rs_class, N_class] = dropnans( ...
    FC_class, ...
    TP_class, ...
    INFO_class,...
    sess_pet_class, ...
    sess_rs_class);

fprintf('\n.Number of subjs removed due to NaNs: %d', sum(N0-N_class));

fprintf('\n..Per class: \n');

disp(N0-N_class);
end

%==========================================================================
function [Y1, Y2] = map_ind1365_to_xxxx(X, I, R)

assert(R==nnz(I));

II = find(I);

Nx = length(X);

Y2 = zeros(Nx,1);

for k=1:Nx

    x = X(k);
    
    assert(x<=1365);
    
    Y2(k) = find(x==II);
    
    assert(Y2(k)<=R);
end

Y1 = false(R,1);

Y1(Y2) = true;
end
