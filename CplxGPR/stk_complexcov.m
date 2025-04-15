function k = stk_complexcov (param, x, y, diff, pairwise, h)

% process input arguments
x = double (x);
y = double (y);
if nargin < 4,  diff = -1;         end
if nargin < 5,  pairwise = false;  end
if nargin < 6,  h = 1e-6;          end

%----- BEGIN BLOCK

% This BLOCK should probably be included in @ComplexCov

% Extract optimizable parameters
p = stk_get_optimizable_parameters (param);

% Get rescaling flags
rescale_flag = (param.rescaling == 'e');
rescale_flag = rescale_flag(1:length(p));

% Rescale
p(rescale_flag) = exp (p(rescale_flag));

%----- END BLOCK

if diff == -1  % Compute the value (not a derivative)

    k = param.CovMat (p, x, y, pairwise);

else  % Compute a derivative

    if param.ana_derivatives

        k = param.CovMat (p, x, y, pairwise, diff);
        if rescale_flag(diff)
            k = k * p(diff);  % Chain rule (exponential rescaling)
        end

    else % Use finite differences

        k0 = param.CovMat (p, x, y, pairwise);
        if rescale_flag(diff)
            p(diff) = p(diff) * exp(h);
        else
            h = abs (p(diff)) * h;
            p(diff) = p(diff) + h;
        end
        k1 = param.CovMat (p, x, y, pairwise);
        k = (k1 - k0) / h;

    end
end

end
