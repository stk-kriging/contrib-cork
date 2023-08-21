function k = stk_complexcov(param, x, y, diff, pairwise,h)

% process input arguments
global CplxCov;
x = double (x);
y = double (y);
if nargin < 4, diff = -1; end
if nargin < 5, pairwise = false; end
if nargin <6, h=1e-6; end

rescale_flag = [CplxCov.rescaling =='e'];
rescale_flag = rescale_flag(1:length(param));

param(rescale_flag)=exp(param(rescale_flag));
K = CplxCov.CovMat(param, x,y,pairwise);

RefMat= stk_dist (x,y,pairwise);
assert(all(size(RefMat)==size(K)));

if diff == -1,
    % compute the value (not a derivative)
    k = K;
else
    % compute a derivative
    if CplxCov.ana_derivatives
        k =CplxCov.CovMat(param,x,y,pairwise,diff);
        if rescale_flag(diff)
            k=k*param(diff); %chain rule (exponential rescaling)
        end
    else %use finite differences
        if rescale_flag(diff)
            param(diff) = param(diff)*exp(h);
        else
            h=abs(param(diff))*h;
            param(diff) = param(diff)+h;
        end
        k = (CplxCov.CovMat(param,x,y,pairwise)-K)/h;
    end
end

end
