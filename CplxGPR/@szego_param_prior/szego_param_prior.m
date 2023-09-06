function obj = szego_param_prior (mode, sigma)

% Parameters:
%  * mode: mode of the pdf of alpha
%  * sigma: standard deviation of log(alpha)

% Mean and standard deviation of the normal prior on log(alpha)
obj.mode  = mode;
obj.mu    = sigma^2 + log(mode);
obj.sigma = sigma;

obj = class (obj, 'szego_param_prior');

end % function
