function [Mean_opt, Var_opt, Var_real_opt, Var_imag_opt, crit_opt, model_opt, residual_opt, data, opt_idx]= AdapApprox(cov_model, xi, yi, x_cv,opts, adap_opts)

% Choose max. number of poles (e.g. "q5" leads to min(n_points/4,5))
if adap_opts.pole_init_method.max_poles(1)=='q'
    adap_opts.pole_init_method.max_poles = min([floor(length(xi)/4),str2num(adap_opts.pole_init_method.max_poles(2:end)),]);
end
if adap_opts.max_poles(1)=='q'
    adap_opts.max_poles = min([floor(length(xi)/4),str2num(adap_opts.max_poles(2:end))]);
end

assert(isempty(opts.poles));

% Restrict the maximum number of poles in any case to (n_points-1)/2
max_num_poles = min(floor((length(xi)-1)/2), adap_opts.pole_init_method.max_poles);
max_dist = inf; % Maximum distance of initial poles. %max(xi)-min(xi)

if ~iscell(adap_opts.pole_init_method.name)
    adap_opts.pole_init_method.name = {adap_opts.pole_init_method.name};
end



%% Model without poles:
if max_num_poles ==0
    opts.tune_poles=false;
    opts.poles = [];
    [data{1}.Mean, data{1}.Var, data{1}.Var_real, data{1}.Var_imag, data{1}.crit, data{1}.model] = CplxGPapprox(cov_model, xi, yi, x_cv,opts);
    opt_idx = 1;
    data{1}.loo_res=loo_res(xi, yi, data{1}.model, adap_opts.model_selection.retune, opts.use_frf_props, adap_opts.model_selection.stability_selection);
else %max_num_poles>0

    %% Determine initial starting poles (max_num_poles) and tune it
    %% (choose best initial model based on likelihood)
    for i = 1:length(adap_opts.pole_init_method.name)

        switch adap_opts.pole_init_method.name{i}
            case 'VF'
                [~, init_poles] = VectorFitting(xi,yi, adap_opts.pole_init_method.VF.Npoles);
                init_poles = -1i*transpose(init_poles);
                init_poles = init_poles(real(init_poles)>=0);
                %% temporary solution (remove imaginary poles)
                init_poles = init_poles([real(init_poles)~=0]);
                init_poles=order_poles(init_poles, min(xi), max(xi), max_dist, max_num_poles);
            case 'equi'
                h=(max(xi)-min(xi))/max_num_poles;
                init_poles = transpose(min(xi)+[0.5:max_num_poles-0.5]*h+1i*adap_opts.pole_init_method.equi.real_part*(max(xi)-min(xi)));
        end

        % Note that AAA and VF can potentially give less than max_num_poles starting poles
        n=length(init_poles);
        assert(n>0);

        %% Model with all poles
        opts.poles = init_poles;
        opts.tune_poles = true;

        if i ==1
            data = cell(n+1,1);
            [data{n+1}.Mean, data{n+1}.Var, data{n+1}.Var_real, data{n+1}.Var_imag, data{n+1}.crit, data{n+1}.model] = CplxGPapprox(cov_model, xi, yi, x_cv,opts);
            if adap_opts.verbose
                fprintf('Approximation with initial poles of %s approach computed.  \n', adap_opts.pole_init_method.name{i})
            end
            crit_opt = data{n+1}.crit;
        else
            [Mean,Var, Var_real, Var_imag, crit, model] = CplxGPapprox(cov_model, xi, yi, x_cv,opts);
            if crit <crit_opt
                data = cell(n+1,1);
                crit_opt = crit;
                if adap_opts.verbose
                    fprintf('Using initial poles of %s approach instead.\n', adap_opts.pole_init_method.name{i})
                end
                data{n+1}.Mean = Mean;
                data{n+1}.Var = Var;
                data{n+1}.Var_real = Var_real;
                data{n+1}.Var_imag = Var_imag;
                data{n+1}.crit = crit;
                data{n+1}.model = model;
            end
        end
    end

    %% Start with poles and parameters of high-dim model
    poles = get_lm_poles(data{n+1}.model.lm);
    cov_param = data{n+1}.model.param;

    while ~isempty(poles)

        % Candidate pole for removing based on likelihood (model with same
        % number of poles -> should be fine); using fixed hyper-parameters
        K = length (poles);
        if K > 1
            critz = zeros(size(poles));
            opts.params = stk_get_optimizable_parameters (cov_param);
            opts.tune_poles=false;
            for i = 1:K
                opts.poles = poles(setdiff(1:K,i));
                [~, ~, ~, ~, critz(i), ~] = CplxGPapprox...
                    (cov_model, xi, yi, x_cv,opts);
            end
            [~, idx] = min (critz);
            poles = poles(setdiff (1:K, idx));
        else
            poles = [];
        end

        % Tune reduced Model
        opts.poles = poles;

        if adap_opts.fast
            opts.p0=opts.params;
            opts.n_restart=0;
        end

        opts.tune_poles = ~isempty(poles);
        opts.params=[];
        [data{n}.Mean, data{n}.Var, data{n}.Var_real, data{n}.Var_imag, data{n}.crit, data{n}.model] = CplxGPapprox(cov_model, xi, yi, x_cv,opts);
        if ~isempty(poles)
            poles = get_lm_poles(data{n}.model.lm);
        end
        if adap_opts.verbose
            fprintf('Removed a pole. New linear model reads:')
            disp(data{n}.model.lm);
        end
        cov_param = data{n}.model.param;
        n=n-1;
    end


    %% Model selection


    if adap_opts.max_poles+1<length(data)
        % It's possible to starting with a larger number of poles than desired
        % for the approximation; in order to ensure a space-filling
        % distribution of starting poles
        data = data(1:adap_opts.max_poles+1);
    end


    %% Select model based on LooResiduals:
    Epsz = Inf(size(data));
    for i = 1:length(data)
        [Epsz(i),data{i}.res2, data{i}.res2loo, data{i}.res2penalty] = loo_res(xi, yi, data{i}.model, adap_opts.model_selection.retune, opts.use_frf_props, adap_opts.model_selection.lambdaz, adap_opts.model_selection.multistart, adap_opts.model_selection.penalty_norm);
        if adap_opts.verbose
            fprintf('Computed residual criterion for model with %i poles: %.2e (Loo: %.2e; Penalty: %.2e.\n',i-1, Epsz(i), mean(data{i}.res2loo), mean(data{i}.res2penalty));
        end
        if adap_opts.refsteps~=Inf
            if all(min(Epsz)<Epsz(i-min(adap_opts.model_selection.refsteps,i)+1:i))
                break;
            end
        end
    end
    if adap_opts.model_selection.normalize %todo: move to loo_res if we keep it
        Epsz = Inf(size(data));
        for i = 1:length(data)
            eps1=  mean(data{i}.res2loo)./mean(data{1}.res2loo);
            eps2 = mean(data{i}.res2penalty)./mean(data{1}.res2penalty);
            Epsz(i) = dot(adap_opts.model_selection.lambdaz, [eps1,eps2]);
            fprintf('Mixed error indicator (%i poles): %.2f. Loo: %.2f. Penalty: %.2f\n',i-1, Epsz(i), eps1, eps2)
        end
    end


    if adap_opts.verbose
        Epsz
    end
    if adap_opts.model_selection.exclude_white_noise
        flag = true;
        while flag
            [~,opt_idx] = min(Epsz);

            % Compute the profile NLL for a model with the same poles
            % but with a white noise kernel instead
            crit_white_noise = proflik_whitenoise ...
                (data{opt_idx}.model, xi, yi, false, false);

            % Exclude the current model if it is worse
            if crit_white_noise < data{opt_idx}.crit
                Epsz(opt_idx)=Inf;
                warning('Excluded model with %i poles (white noise kernel)\n', opt_idx-1)
                if all(Epsz==Inf)
                    warning('Only white noise models available -> choose model with 0 poles')
                    opt_idx=1;
                    flag=false;
                end
            else
                flag=false;
            end
        end
    else
        [~,opt_idx] = min(Epsz);
    end

    if adap_opts.verbose
        fprintf('Model selected with %i pole(s).\n', opt_idx-1);
    end
end

%% Assign output values of optimal model
Mean_opt = data{opt_idx}.Mean;
Var_opt = data{opt_idx}.Var;
Var_real_opt = data{opt_idx}.Var_real;
Var_imag_opt = data{opt_idx}.Var_imag;
crit_opt = data{opt_idx}.crit;
model_opt = data{opt_idx}.model;
residual_opt = data{opt_idx}.res2;

%% Assert model with more poles is better than model with less poles (in terms of likelihood)
for i = 1:length(data)-1
    if data{i+1}.crit>data{i}.crit
        warning('Something went wrong during the adaptive procedure. Adding poles does not improve the likelihood');
    end
end

end

