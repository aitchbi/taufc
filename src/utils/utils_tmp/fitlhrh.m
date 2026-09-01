function [r2l, r2r, mdl_lh, mdl_rh] = fitlhrh(X, tpicis, reg1, reg2, reg3)
if isstruct(X)
    assert(all(isfield(X, {'lh', 'rh'})));
    assert(~exist('reg1', 'var'), 'extend code as below');
    assert(~exist('reg2', 'var'));
    assert(~exist('reg3', 'var'));
    
    XX_lh = X.lh;
    XX_rh = X.rh;
    
    assert(length(tpicis)==size(XX_lh,1));
    assert(length(tpicis)==size(XX_rh,1));
else

    Nr = size(X,1);
    Nr_hemi = floor(Nr/2);
    
    if exist('reg1', 'var')
        if exist('reg2', 'var')
            if exist('reg3', 'var')
                XX_lh = [reg1 reg2 reg3 X(:,1:Nr_hemi)];
                XX_rh = [reg1 reg2 reg3 X(:,(Nr_hemi+1):Nr)];
            else
                XX_lh = [reg1 reg2 X(:,1:Nr_hemi)];
                XX_rh = [reg1 reg2 X(:,(Nr_hemi+1):Nr)];
            end
        else
            assert(~exist('reg3', 'var'));
            XX_lh = [reg1 X(:,1:Nr_hemi)];
            XX_rh = [reg1 X(:,(Nr_hemi+1):Nr)];
        end
    else
        assert(~exist('reg2', 'var'));
        assert(~exist('reg3', 'var'));
        XX_lh = [X(:,1:Nr_hemi)];
        XX_rh = [X(:,(Nr_hemi+1):Nr)];
    end
end

mdl_lh = fitlm(XX_lh, tpicis);
mdl_rh = fitlm(XX_rh, tpicis);

r2l = mdl_lh.Rsquared.Adjusted;
r2r = mdl_rh.Rsquared.Adjusted;
end
