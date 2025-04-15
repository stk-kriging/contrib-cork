function [param, lnv] = stk_complexcov_param_init (model, varargin)

param = model.param;
assert (isa (param, 'ComplexCov'));

[p0, lnv] = param.get_params_init (varargin{:});
param = stk_set_optimizable_parameters (param, p0);

end % function
