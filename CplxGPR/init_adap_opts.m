function [opts] = init_adap_opts()

opts.pole_init_method.name='equi'; %{'VF','equi'} would try both, VF and equidistant distribution, for the starting poles
opts.max_poles='q5'; % It will restrict to the minimum of 5 and a quarter of the number of the training points
opts.pole_init_method.max_poles='q5'; % It will restrict to the minimum of 5 and a quarter of the number of the training points
opts.model_selection.retune = true; % "expensive" residuals (alternative: "cheap" standard residuals)
opts.model_selection.lambdaz=[1,0.2]; % factors for loo residual and instability penalty
opts.model_selection.multistart=0;
opts.model_selection.exclude_white_noise=false;
opts.model_selection.refsteps=inf;
opts.model_selection.penalty_norm=1; % 1: mean of squared variation. 0: max of squared variation
opts.model_selection.normalize=1; % Normalize both error indicators w.r.t. error indicators of zero mean model
opts.pole_init_method.equi.real_part = 1e-3; % real part of equidistant starting poles
opts.pole_init_method.VF.Npoles = Inf; % number of poles of VF starting poles
opts.fast=false;
opts.refsteps=inf;
opts.verbose=false;

end
