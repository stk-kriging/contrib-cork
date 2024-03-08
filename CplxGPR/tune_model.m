function [model_opt, crit_opt] = tune_model(model, xi_cplx, yi_cplx, opts)

n=length(xi_cplx);

% If no initial kernel hyper-parameters p0 are given:
% compute p0 by tuning with fixed poles (n/2 restarts)
if opts.tune_poles && isempty(opts.p0) && opts.tune_kernel_first
    lm_rat = model.lm;
    %model.lm = @(x) [~x(:,end), x(:,end)]; % Ordinary Kriging
    model.lm = stk_lm_rat(opts.poles, false, opts.pole_bounds, opts.use_frf_props, opts.use_zero_mean);
    opts2=opts;
    opts2.tune_poles=false;
    opts2.n_restart=floor(opts2.n_restart/2);
    model = tune_model(model, xi_cplx, yi_cplx, opts2);
    model.lm = lm_rat;
    opts.p0 = stk_get_optimizable_parameters (model.param);
end

% If no initial kernel hyper-parameters are given: use default values for
% all parameters, except for the sigma2, which is obtained by profiling
if isempty (opts.p0)

    % Set sigma^2 to 1 before calling stk_param_init? Why?
    % FIXME: Temporarily commented out. Investigate / explain...
    % model.param.sigma2 = 1;

    opts.p0 = stk_param_init (model, xi_cplx, yi_cplx);
    model.param = stk_set_optimizable_parameters (model.param, opts.p0);

    % Compute profiled sigma^2
    model.param.sigma2 = compute_profiled_sigma2 (model, xi_cplx, yi_cplx);

end

try
    [model_init, info_init] = stk_param_estim_(model, xi_cplx, yi_cplx, opts.p0, [], @stk_param_proflik);
catch e
    fprintf(1,'The identifier was:\n%s',e.identifier);
    fprintf(1,'There was an error during initial tuning! The message was:\n%s',e.message);
    info_init.crit_opt = Inf;
    model_init=model;
end

crit_opt = info_init.crit_opt;
model_opt = model_init;

if opts.n_restart
    orig_warning_state = warning('off', 'STK:stk_param_estim_optim:NoImprovement');
    rng(23)
    for i = 1:opts.n_restart

        % Draw random parameters
        model.param = set_random_param (model.param);
        p0 = stk_get_optimizable_parameters (model.param);

        % Compute profiled sigma^2
        model.param.sigma2 = compute_profiled_sigma2 (model, xi_cplx, yi_cplx);

        try
            [model_new, info] = stk_param_estim_ (model, ...
                xi_cplx, yi_cplx, p0, [], @stk_param_proflik);
            if info.crit_opt <crit_opt
                crit_opt = info.crit_opt;
                model_opt = model_new;
            end
            % fprintf('P0: %f, %f. Parameter: %f, %f. Criterion: %f.\n', p0(1), p0(2), model_new.param(1), model_new.param(2), info.crit_opt);
        catch e %e is an MException struct
            fprintf(1,'The identifier was:\n%s',e.identifier);
            fprintf(1,'There was an error during tuning restart! The message was:\n%s',e.message);
            % more error handling...
        end
    end
    if opts.verbose
        fprintf('Optimal criterion: %f. At initial point: %f\n', crit_opt, info_init.crit_opt);
        fprintf('Estimated Parameters: ')
        fprintf('%g ', model_opt.param);
        fprintf('\n');
    end
    warning(orig_warning_state);
end

end
