function [v_p,N_p] = biofinder_chkloadparcels(f_p,h_s)

[v_p, h_p] = hb_nii_load(f_p, 'DuplicateThenUnzip', true);

hb_nii_verify_space_match(h_p, h_s);

N_p = length(setxor(unique(v_p(:)),0));
end
