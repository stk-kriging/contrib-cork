% Returns epsilon (penalized leave-on-out criterion): Mean of res2, where in turn
% res2 is the weighted sum of the squared loo-residual res2Loo and penalty term res2Penalty
function [eps, res2, res2Loo, res2Penalty, plotData] = loo_res(xi, yi, model, exp, use_frf_props,lambdaz, n_multistart,penaltynorm)

if nargin <4
    exp=true; % "expensive" evaluation, i.e. with retuning
end

if nargin<5
    use_frf_props=false; %If yes: exclude imaginary part of value at w=0
end

if nargin<6
    lambdaz = [1,0.1]; % Coefficients for loo residual and instability penalty
end

if nargin<7
    n_multistart=0;
end

if nargin<8
    penaltynorm=1;
end

p0 = model.param;
model_init = model;

%[lb, ub] = stk_param_getdefaultbounds (model, xi, yi);
% assert( ~((any (lb == -inf) || any (ub == +inf))));

%% Compute original reference predition (for penalty part)
[xi_cplx,yi_cplx] = mapCplxData(xi,yi,use_frf_props);
x_cv=linspace(min(xi), max(xi), length(xi)*10+1)';
x_cv_cplx = mapCplxData(x_cv, [], false);
ref_pred_cplx=stk_predict(model, xi_cplx, yi_cplx, x_cv_cplx);
ref_pred = ref_pred_cplx.mean(1:end/2)+1j*ref_pred_cplx.mean(end/2+1:end);

%% Initialization of options for multistart procedure
if n_multistart
    assert(exp)
    opts=init_opts();
    opts.n_restart=n_multistart;
    if isa(model.lm, 'stk_lm_null')
        opts.tune_poles=false;
    elseif isa(model.lm, 'stk_lm_rat')
        opts.tune_poles=true;
        opts.poles = get_lm_poles(model.lm);
    else
        error;
    end
end

if nargout>4
    plotData.x_cv = x_cv;
    plotData.ref_pred = ref_pred;
    plotData.predz = cell(length(xi),1);
end


%% Compute residuals
res2Loo=zeros(size(xi));
res2Penalty = zeros(size(xi));
for i =1:length(xi)
    % fprintf('Residual: consider point %i of %i.', i, length(xi));
    %% Reduced training data:
    [xi_cplx,yi_cplx] = mapCplxData(xi(setdiff(1:end,i)),yi(setdiff(1:end,i)), use_frf_props);

    if exp % Retune:
        [model_opt, info] = stk_param_estim_(model_init, xi_cplx, yi_cplx, p0, [], @stk_param_proflik);
        crit_opt = info.crit_opt;
        % [msg,warnID] = lastwarn;
        if n_multistart
            [model, crit]=tune_model(model_init, xi_cplx, yi_cplx, opts);
            if crit<crit_opt
                model_opt=model;
            end
        end
        model = model_opt;
    end

    %% Loo:
    x_loo_cplx = mapCplxData(xi(i), [],false);
    pred_cplx=stk_predict(model, xi_cplx, yi_cplx, x_loo_cplx);
    pred = pred_cplx.mean(1)+1j*pred_cplx.mean(2);
    res2Loo(i) = abs(pred-yi(i))^2;

    %% Stability penalty on fine grid
    pred_cplx=stk_predict(model, xi_cplx, yi_cplx, x_cv_cplx);
    pred = pred_cplx.mean(1:end/2)+1j*pred_cplx.mean(end/2+1:end);
    if penaltynorm==1
        res2Penalty(i) = mean(abs(ref_pred-pred).^2);
    elseif penaltynorm==0
        res2Penalty(i) = max(abs(ref_pred-pred).^2);
    end
    if nargout>4
        plotData.predz{i} = pred;
    end
end

res2=lambdaz(1)*res2Loo+lambdaz(2)*res2Penalty;
eps = mean(res2);

end
