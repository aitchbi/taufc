function [fcall, Nall, fclbls] = getallfc(FC, N)

Nc = length(FC);

Nr = size(FC{1},1);

Nall = sum(N);

fcall = zeros(Nr, Nr, Nall);

Ncumsum = cumsum(N);

fclbls = zeros(2,Nall);

for ic=1:Nc

    if ic==1
    
        d1 = 1;
    
    else
    
        d1 = Ncumsum(ic-1)+1;
    end
    
    d2 = Ncumsum(ic);
    
    fcall(:,:,d1:d2) = FC{ic};
    
    fclbls(1,d1:d2) = ic;
    
    fclbls(2,d1:d2) = 1:N(ic);
end
end