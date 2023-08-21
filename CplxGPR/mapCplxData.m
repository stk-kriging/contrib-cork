function [x_cplx, y_cplx] = mapCplxData(x, y, use_frf_props)

    if nargin<3
        use_frf_props=false; % if true: remove imag. part at x=0
    end
    
    assert(iscolumn(x))
    assert(iscolumn(y)||isempty(y))
    
    %% Apply mapping A for complex training/test data
    x_cplx = [repmat(x,2,1),[zeros(size(x,1),1); ones(size(x,1),1)]];
    y_cplx = [real(y); imag(y)];
    
    if use_frf_props && any(x==0)
        %% Treat w=0 suitable: Use non-intrusive real/complex GP by removing data of imag. part
        idx = ~all(x_cplx == [0,1],2);
        assert(sum(~idx)==1);
        x_cplx = x_cplx(idx,:);
        if ~isempty(y)
            if ~abs(y_cplx(~idx))<1e-10
               warning('Removing non-zero imaginary part at zero frequency');
            end
            y_cplx = y_cplx(idx,:);
        end
    end
 
end

