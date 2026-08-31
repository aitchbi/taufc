function Y = hb_fc_verify(Y, varargin)

ValidFormats = {'Symmetric', 'UpperTriangular', 'LowerTriangular', 'Unknown'};

funcVald = @(x) and(funcChar(x), ismember(x, ValidFormats));

p = inputParser;

addParameter(p,'Format', 'Unknown', funcVald);

parse(p,varargin{:});

opts = p.Results;

if iscell(Y)
    CellInput = true;
else
    Y = {Y};
    CellInput = false;
end

C = length(Y);

for ic=1:C

    X = Y{ic};

    % Convert triu/tril matrices to full.
    switch ndims(X)

        case 2

            switch opts.Format
            
                case 'Symmetric'
                
                    assert(issymmetric(X(:,:)));

                case {'UpperTriangular', 'LowerTriangular'}
                    
                    X = X+X';

                case 'Unknown'
                    
                    if issymmetric(X)
                    
                        format1(1,[]);
                    
                    else
                    
                        [~, X] = format23(1,[],X);
                    end
            end

        case 3
            
            TheFormat = [];
            
            for k=1:size(X,3)
            
                switch opts.Format
                
                    case 'Symmetric'
                    
                        assert(issymmetric(X(:,:,k)));

                    case {'UpperTriangular', 'LowerTriangular'}
                        
                        X(:,:,k) = X(:,:,k) + X(:,:,k)';

                    case 'Unknown'
                        
                        d = X(:,:,k);
                        
                        if issymmetric(d)
                        
                            TheFormat = format1(k,TheFormat);
                        
                        else
                        
                            [TheFormat, X(:,:,k)] = format23(k,TheFormat,d);
                        end
                end
            end
    end

    %-Check presence of zero-rows/columns or NaNs.
    if C==1
    
        tc = '';
    
    else
        
        tc = sprintf('[class %d]', ic);
    end
    
    switch ndims(X)
    
        case 2
        
            d = sum(abs(X));
            
            t1 = sprintf('FC has zeros columns. %s', tc);
            
            t2 = sprintf('FC has NaNs. %s', tc);
            
            assert(not(any(d==0)),     t1);
            
            assert(not(any(isnan(d))), t2);
        
        case 3
        
            M = size(X,3);
            
            N_zeros = zeros(M, 1);
            
            N_nans  = zeros(M, 1);
            
            for k=1:M
            
                xk = X(:,:,k);
                
                d = sum(abs(xk));
                
                N_zeros(k) = nnz(d)==0;
                
                N_nans(k) = nnz(isnan(d));
            end
            
            n1 = nnz(N_zeros);
           
            n2 = nnz(N_nans);
            
            t1 = sprintf('%d FCs have zeros columns. %s', n1, tc);
            
            t2 = sprintf('%d FCs have NaNs. %s', n2, tc);
            
            assert(n1==0, t1);
            
            assert(n2==0, t2);
    end

    %-Update.
    Y{ic} = X;
end

if ~CellInput

    assert(C==1);
    
    Y = Y{1};
end
end

%==========================================================================
function c = dochk(d)

d1 = isequal(d, triu(d));

d2 = isequal(d, tril(d));

c = or(d1,d2);
end

%==========================================================================
function TheFormat = format1(k,TheFormat)

if k==1

    fprintf('\n.Input FC is symmetric. Returned unchanged.');
    
    TheFormat = '1';

else

    assert(isequal(TheFormat, '1'));
end
end

%==========================================================================
function [TheFormat, d] = format23(k,TheFormat,d)

if dochk(d)

    if k==1
    
        fprintf('\n.Input FC is triangular. Symmetrized matrix returned.');
        
        TheFormat = '2';
    
    else
    
        assert(isequal(TheFormat, '2'));
    
    end
    
    d = d + d';

else

    if k==1
    
        fprintf('\n.Input FC not symmetric/triangular. Returned unchanged.');
        
        TheFormat = '3';
    
    else
    
        assert(isequal(TheFormat, '3'));
    end
end
end