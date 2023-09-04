function [lb, ub] = stk_complexcov_getdefaultbounds (param0, xi,zi)

global CplxCov;
[lb,ub] = CplxCov.get_bounds(param0, xi,zi);

end
