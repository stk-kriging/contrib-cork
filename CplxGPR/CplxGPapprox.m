function [Mean, Var, Var_real, Var_imag, crit_opt, model] = CplxGPapprox(cov_model, xi, yi, x_cv,opts)

%% Real-valued representation of complex training data
[xi_cplx, yi_cplx] = mapCplxData(xi,yi, opts.use_frf_props);


%% Create model
global CplxCov;
CplxCov = make_ComplexCov (cov_model);
model = stk_model('stk_complexcov', 2);
model.lognoisevariance=opts.lnv;
if ~isempty(opts.lb) && ~isempty(opts.ub)
    CplxCov=CplxCov.set_bounds(opts.lb, opts.ub)
else
    if strcmp (cov_model, 'Szego')
        [lb,ub] = CplxCov.get_bounds();
        lb(2) = lb(2)*(max(xi)-min(xi));
        ub(2) =    ub(2)*(max(xi)-min(xi));
        CplxCov=CplxCov.set_bounds(lb, ub);
    end
end

if isempty (opts.p0) && strcmp (cov_model, 'Szego')
    [param0, lnv]  = CplxCov.get_params_init();
    param0(2) = param0(2)*(max(xi)-min(xi)); % rescale w.r.t. size of interval
    CplxCov = CplxCov.set_params_init(param0, lnv);
end

if strcmp (cov_model, 'Szego') && isfield (opts, 'SzegoPrior')
    mode = opts.SzegoPrior(1) * (max(xi) - min(xi));
    sigma = opts.SzegoPrior(2);
    model.prior = szego_param_prior (mode, sigma);
end

%% Set linear model
assert(~isempty(opts.poles)||~opts.tune_poles);
if isempty(opts.poles)
    if opts.use_zero_mean
        model.lm = stk_lm_null;
    else
        model.lm = @(x) [~x(:,end), x(:,end)]; % Ordinary Kriging
    end
else
    if any(imag(opts.poles)<0) && opts.stable
        fprintf('Poles with negative imaginary part detected. Flipping signs..\n')
        idx = (imag(opts.poles)<0);
        opts.poles(idx) = conj(opts.poles(idx));
    end

    % Ensure that no poles are (numerically) too close to the axis
    %imag_min = min(diff(xi))*1e-2;
    imag_min = 1e-6*(max(xi)-min(xi));

    idx = (imag(opts.poles)<imag_min);
    opts.poles(idx) = real(opts.poles(idx))+1i*imag_min;

    if isempty(opts.pole_bounds)
        dx = max(xi)-min(xi);
        min_r = max(min(min(xi)-dx/3, min(real(opts.poles))), 1e-6*(max(xi)-min(xi)));%&,1e-2*(max(xi)-min(xi)))
        lb_poles = [repmat(min_r,length(opts.poles),1); ...
            repmat(min(imag_min,min(imag(opts.poles))), length(opts.poles),1)];
        ub_poles = [repmat(max(max(xi)+dx/3, max(real(opts.poles))),length(opts.poles),1);  ...
            repmat(max(dx, max(imag(opts.poles))),length(opts.poles),1)];
        opts.pole_bounds = [lb_poles, ub_poles];
    end

    % Set rational linear model
    model.lm = stk_lm_rat(opts.poles, opts.tune_poles, opts.pole_bounds, opts.use_frf_props, opts.use_zero_mean);
end


if isempty(opts.params)
    %% Tune model
    %optim_opts = stk_options_get('stk_param_estim');
    %optim_opts.minimize_box = stk_optim_fmincon();
    %stk_options_set('stk_param_estim', optim_opts);
    [model, crit_opt] = tune_model(model, xi_cplx, yi_cplx, opts);
else
    %% Set hyper-parameters and evaluate likelihood
    model.param = opts.params;
    crit_opt = stk_param_proflik(model, xi_cplx, yi_cplx);
end


%% Prediction
n_cv = size(x_cv,1);
x_cv_cplx = mapCplxData(x_cv,[], false);
SurKriging_cplx=stk_predict(model, xi_cplx, yi_cplx, x_cv_cplx);
Mean = SurKriging_cplx.mean(1:n_cv)+1j*SurKriging_cplx.mean(n_cv+1:2*n_cv);
Var_real = SurKriging_cplx.var(1:n_cv);
Var_imag = SurKriging_cplx.var(n_cv+1:2*n_cv);
Var = Var_real+Var_imag;

end
