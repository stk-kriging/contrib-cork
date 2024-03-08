function [lb, ub] = stk_complexcov_getdefaultbounds (param0, xi, zi)

%----- BEGIN BLOCK

% This BLOCK should probably be included in @ComplexCov

% Extract optimizable parameters
p = stk_get_optimizable_parameters (param);

% Note: here we are passing raw (not rescaled) parameters to get_bounds

% Call @ComplexCov.get_bounds
[lb, ub] = param0.get_bounds (p, xi, zi);

%----- END BLOCK

end
