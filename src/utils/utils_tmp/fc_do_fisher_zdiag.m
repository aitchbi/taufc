function [FC_class, FC_class_noFisherZtrans] = fc_do_fisher_zdiag(FC_class, FC_FisherZTrans, FC_ZeroDiag)

if FC_FisherZTrans

    FC_class_noFisherZtrans = FC_class;

else

    FC_class_noFisherZtrans = [];
end

if FC_FisherZTrans
    
    FC_class = hb_fc_fishertrans(FC_class);
end

if FC_ZeroDiag
    
    FC_class = hb_fc_zerodiag(FC_class);
    
    if FC_FisherZTrans
    
        FC_class_noFisherZtrans = hb_fc_zerodiag(FC_class_noFisherZtrans);
    end
end
end