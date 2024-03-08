function sigma2 = compute_profiled_sigma2 (model, xi, zi)

assert (isa (model.param, 'ComplexCov'));

% Set sigma^2 to 1 before calling stk_param_gls
model.param.sigma2 = 1.0;

% Estimate beta using the GLS method
[beta, sigma2] = stk_param_gls (model, xi, zi);

% Sample size
n = size (xi, 1);

% Number of parameters
p = length (beta);

% Since we're doing ML and not ReML in this project, we have to
% fix the normalizing constant of the variance estimate
sigma2 = (n - p) / n * sigma2;

end % function
