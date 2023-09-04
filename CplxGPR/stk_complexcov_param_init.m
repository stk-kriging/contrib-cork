function [param0, lnv] = stk_complexcov_param_init (model, varargin)

global CplxCov;

[param0, lnv] = CplxCov.get_params_init(varargin{:});

end
