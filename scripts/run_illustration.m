%% Test complex 1D example
clf; close all; clear;

%% Function to approximate (either function or training+test-data)
%f = @(omega) fun_Circuit(omega, 500, 6,0.2); xmin=1; xmax=2.5; fun='Circuit'; discrete_data=false;
f = @(ref_level) fun_VibroAcoustics(ref_level); fun='VibroAcoustics'; discrete_data=true;
%f = @(ref_lev) fun_Spiral(ref_lev); discrete_data=true;

if ~discrete_data

    %% Training points:
    n_training_points = 40;
    noise_std=0.0;

    xi = linspace(xmin,xmax,n_training_points)';
    yi = f(xi);
    rng(23)
    lnv=2*log(noise_std);
    yi = yi+ noise_std*(randn(size(xi))+1i*randn(size(xi)));


    %% Test points
    n_cv = 201;
    %x_cv = unique(sort([linspace(xmin,xmax,n_cv)',xi]));
    x_cv = linspace(xmin,xmax,n_cv)';
    y_cv = f(x_cv);


else

    %% Training and test points;
    ref_level=18; % (Refinement level for training points)
    [xi, yi, x_cv, y_cv] = f(ref_level);
    [x_cv,idx] = sort([x_cv;xi]);
    y_cv = [y_cv; yi];
    y_cv = y_cv(idx);
    [x_cv,idx] = unique(x_cv);
    y_cv = y_cv(idx);
    n_training_points = length(xi);

end

%% Illustrate function:
plot_cplxfun(x_cv,y_cv, 'Reference', 'k-')
plot_cplxfun(xi, yi, 'Data for Fitting', 'kx')

%% AAA
[approxAAA, polesAAA] = aaa(yi,xi);
plot_cplxfun(x_cv, approxAAA(x_cv), 'AAA', '--');
[RMSE_AAA, max_errorAAA] = compute_approx_error(approxAAA(x_cv), y_cv, 'AAA');

%% Vector Fitting (using complex starting poles):
[approxVF, polesVF] = VectorFitting(xi,yi);
plot_cplxfun(x_cv, approxVF(x_cv), 'VectorFitting Approx', '--');
[RMSE_VF, max_errorVF] = compute_approx_error(approxVF(x_cv), y_cv, 'VF');

%% Separate Kriging Approximation
Mean = SepKrigingApprox('stk_gausscov_iso', xi, yi, x_cv,  [], 1, -30);
plot_cplxfun(x_cv, Mean, 'SepKriging Approx', '--');
[RMSE_VF, max_errorVF] = compute_approx_error(Mean, y_cv, 'SepKriging');

%% Szegö
opts=init_opts();
[Mean, Var, Var_real, Var_imag, crit_opt, model] = CplxGPapprox('Szego', xi, yi, x_cv, opts);%, [-5; -1], [5;5]);%,[],[],[],0,[1, 1e-3]);
plot_cplxfun(x_cv, Mean, ['Szego'], 'b:');
[RMSE_Szego, max_errorSzego] = compute_approx_error(Mean, y_cv, 'Szego');

%% Adaptive Approximation
adap_opts = init_adap_opts();
%opts.verbose=true;
adap_opts.verbose=true;
opts.n_restart=5;
%adap_opts.model_selection.lambdaz = [1 0]; adap_opts.model_selection.normalize=0; % Set LOO
%adap_opts.model_selection.lambdaz = [1, 0.2]; adap_opts.model_selection.normalize=0; adap_opts.model_selection.penalty_norm=1;% Set JB criterion
[Mean,Var, Var_real, Var_imag,crit,adap_model,res, data] = AdapApprox('Szego', xi, yi, x_cv,opts, adap_opts);
plot_cplxfun(x_cv, Mean, 'Adap Approx', '--');
[RMSE_Adap, max_errorAdap] = compute_approx_error(Mean, y_cv, 'Adap');


for i = 1:length(data)
    compute_approx_error(data{i}.Mean, y_cv, ['Model with ' num2str(i-1) ' poles']);
end
