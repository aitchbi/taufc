function y = biofinder_getdaysdiff(d1, d2)

if ischar(d1)

    d1 = str2double(d1);
    
    N1 = 1;

else

    N1 = length(d1);
end

if ischar(d2)

    d2 = str2double(d2);
    
    N2 = 1;

else

    N2 = length(d2);
end

assert(N1==N2);

y = zeros(size(d1));

for k=1:N1

    d1k = datetime(d1(k), 'ConvertFrom', 'yyyymmdd');
    
    d2k = datetime(d2(k), 'ConvertFrom', 'yyyymmdd');
    
    y(k) = days(d1k-d2k);
end
end
