function Ao = hb_orth(A, B)
% HB_ORTH Orthogonalises A with respect to B. 
% B unchanged. 
% A changed. 
%
% h behjat

assert(all(~isnan(A)), 'Input A has NaNs.');

assert(all(~isnan(B)), 'Input B has NaNs.');

if norm(B)==0

    Ao = A;

else

    projB_A = dot(A, B) / norm(B)^2 * B;
    
    Ao = A - projB_A;
end

assert(dot(Ao, B)<=1e-6, 'Low-precision orthogonality.');
end

