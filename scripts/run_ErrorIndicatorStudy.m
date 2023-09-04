clf; close all; clear;

%% Settings:
recompute=true;
noise_std=0;

%% Functions to approximate
for kk = [1:2]
    switch kk
        case 1
            f = @(ref_lev) fun_VibroAcoustics(ref_lev); Nz = 7:38; fun_name='VibroAcoustics'; discrete_data  =true;
        case 2
            f = @(ref_lev) fun_Spiral(ref_lev); fun_name='Spiral'; Nz = 12:2:48; discrete_data  =true;
        case 3
            f = @(ref_lev) fun_WGjunctionS21(ref_lev); fun_name='WGjunctionS21'; Nz = 4:14; discrete_data  =true;
        case 4
            f = @(ref_lev) fun_WGjunctionS41(ref_lev); fun_name='WGjunctionS41'; Nz = 4:14; discrete_data  =true;
        case 5
            f = @(ref_lev) fun_pacmanRight(ref_lev); fun_name='PacmanRight'; Nz = 1:9; discrete_data  =true;
        case 6
            dom_poles=true; n_elements=1000; n_cv=201; xmin=1; xmax=2.5;
            f = @(omega) fun_Circuit(omega,n_elements, 1, 0.2, dom_poles);
            fun_name=['CircuitDomPoles'];
            discrete_data = false;
            Nz = 20:2:80;
        case 7
            dom_poles=false; n_elements=1000; n_cv=201; xmin=1; xmax=2.5;
            f = @(omega) fun_Circuit(omega,n_elements, 1, 0.2, dom_poles);
            fun_name=['Circuit'];
            discrete_data = false;
            Nz = 20:2:80;
    end

    methods={}; % Initialize
    opts = init_opts();
    adap_opts = init_adap_opts();
    adap_opts.model_selection.retune=false;

    data_errors = nan(length(Nz), 6); % Maximal 6 models per point
    data_error_per_crit = NaN(length(Nz), 6); % 6 different possible criterions

    for i = 1:length(Nz)
        fprintf('Run %i of %i.\n', i, length(Nz));

        N = Nz(i);

        if ~discrete_data

            %% Training points:
            xi = linspace(xmin,xmax,N)';
            yi = f(xi);

            %% Test points
            n_cv = 201;
            x_cv = linspace(xmin,xmax,n_cv)';
            y_cv = f(x_cv);

        else

            %% Training and test points;
            [xi, yi, x_cv, y_cv] = f(N);

        end

        [~, ~, ~, ~, ~, ~, ~, data, ~] = AdapApprox('Szego', xi, yi, x_cv, opts, adap_opts);

        errz = zeros(length(data),1);
        for j = 1:length(data)
            errz(j) = compute_approx_error(data{j}.Mean, y_cv, false);
            data_errors(i,j) = errz(j);
        end

        for exp = [false, true]

            loo_crit = zeros(length(data),1);
            stability_crit = zeros(length(data),1);
            combined_crit = zeros(length(data),1);

            for j = 1:length(data)
                [~,~, res2Loo, res2Penalty] = loo_res(xi, yi,data{j}.model, exp, true);
                if j ==1
                    n1 = mean(res2Loo);
                    n2 = mean(res2Penalty);
                end
                loo_crit(j) = mean(res2Loo)/n1;
                stability_crit(j) = mean(res2Penalty)/n2;
                combined_crit(j) = loo_crit(j)+0.2*stability_crit(j);
            end
            [~,idx] = min(loo_crit);
            data_error_per_crit(i,1+3*exp) = errz(idx);
            [~,idx] = min(stability_crit);
            data_error_per_crit(i,2+3*exp) = errz(idx);
            [~,idx] = min(combined_crit);
            data_error_per_crit(i, 3+3*exp) = errz(idx);

        end
    end

    Ns = zeros(size(Nz));
    for i = 1:length(Nz)
        if discrete_data
            Ns(i) = length(f(Nz(i)));
        else
            Ns(i) = Nz(i);
        end
    end


    figure(kk)
    semilogy(Ns, data_errors, 'kx')
    hold on;
    semilogy(Ns, data_error_per_crit(:,1), 'DisplayName', 'LOO-Cheap')
    %semilogy(Ns, data_error_per_crit(:,2), 'DisplayName', 'Stability-Cheap')
    %semilogy(Ns, data_error_per_crit(:,3), 'DisplayName', 'Combined-Cheap')
    semilogy(Ns, data_error_per_crit(:,4), 'o-', 'DisplayName', 'Loo-Exp')
    semilogy(Ns, data_error_per_crit(:,5), 'x-','DisplayName', 'Stability-Exp')
    semilogy(Ns, data_error_per_crit(:,6), 'DisplayName', 'Combined-Exp')
    title(fun_name)
    legend;

    export_csv(['results/AllErrors_' fun_name '.csv'], [Ns',data_errors], 'N, e1,e2,e3,e4,e5,e6');
    export_csv(['results/ModelSelectionConv' fun_name '.csv'], [Ns', data_error_per_crit], 'N, LooCheap, StabCheap, CombCheap, LooExp, StabExp, CombExp')
end