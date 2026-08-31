function TmplFC = get_templateFC(WhichFCTemplate, FC_class_noFisherZtrans, lbls, Do_ZeroDiag, Do_FisherZTrans)

Nc = length(FC_class_noFisherZtrans);

[sts, d] = ismember(WhichFCTemplate, lbls);

assert(sts);

TmplFC = mean(FC_class_noFisherZtrans{d}, 3);

if iscell(TmplFC)

    for ic=1:Nc
    
        verifyfc(TmplFC{ic});
        
        TmplFC{ic} = processfc(TmplFC{ic}, Do_FisherZTrans, Do_ZeroDiag);
    end

else

    verifyfc(TmplFC);
    
    TmplFC = processfc(TmplFC, Do_FisherZTrans, Do_ZeroDiag);
end
end

%==========================================================================
function verifyfc(d)

assert(min(d(:)) >= -1);

assert(max(d(:)) <= 1);
end

%==========================================================================
function d = processfc(d,Do_FisherZTrans,Do_ZeroDiag)

if Do_FisherZTrans

    d = hb_fc_fishertrans(d);
end

if Do_ZeroDiag

    d = hb_fc_zerodiag(d);
end
end

