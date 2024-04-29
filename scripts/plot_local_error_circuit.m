%% Plot illustration of different approximations and associated pointwise error for Circuit example
clf; close all; clear;

%% Function to approximate (Circuit with/without dominant poles)
% f = @(omega) fun_Circuit(omega, 1000, 1,0.2, true); xmin=1; xmax=2.5; fun='Circuit'; 
f = @(omega) fun_Circuit(omega, 1000, 1,0.2, false); xmin=1; xmax=2.5; fun='Circuit'; 

%% Training points:
n_training_points = 50;
xi = linspace(xmin, xmax, n_training_points)';
yi = f(xi);

%% Test points
n_cv = 501;
%x_cv = unique(sort([linspace(xmin,xmax,n_cv)',xi]));
x_cv = linspace(xmin,xmax,n_cv)';
y_cv = f(x_cv);


%% Set up Export Data
export_data = zeros(n_cv, 10); header = {};
export_data(:, 1) = 1e4 * x_cv; header{1} = 'x';
export_data(:, 2) = abs(y_cv); header{2} = 'y_ref_abs';


%% Illustrate function:
plot_cplxfun(x_cv,y_cv, 'Reference', 'k-')
plot_cplxfun(xi, yi, 'Data for Fitting', 'kx')

%% AAA
[approxAAA, polesAAA] = aaa(yi,xi);
plot_cplxfun(x_cv, approxAAA(x_cv), 'AAA', '--');
plot_cplxfun(x_cv, approxAAA(x_cv)-y_cv, 'Error AAA', 'b-',  [], [], [], 100)
figure(1000)
semilogy(x_cv, abs(approxAAA(x_cv)-y_cv), 'b-', 'DisplayName', 'AAA')
hold on
export_data(:, 3) = abs(approxAAA(x_cv)); header{3} = 'AAA';
export_data(:, 4) = abs(approxAAA(x_cv)-y_cv); header{4} = 'Error_AAA';

[RMSE_AAA, max_errorAAA] = compute_approx_error(approxAAA(x_cv), y_cv, 'AAA');

%% Vector Fitting (using complex starting poles):
[approxVF, polesVF] = VectorFitting(xi,yi);
plot_cplxfun(x_cv, approxVF(x_cv), 'VectorFitting Approx', '--');
plot_cplxfun(x_cv, approxVF(x_cv)-y_cv, 'Error VF', 'r--',  [], [], [], 100)
figure(1000)
semilogy(x_cv, abs(approxVF(x_cv)-y_cv), 'r--', 'DisplayName', 'VF')
[RMSE_VF, max_errorVF] = compute_approx_error(approxVF(x_cv), y_cv, 'VF');
export_data(:, 5) = abs(approxVF(x_cv)); header{5} = 'VF';
export_data(:, 6) = abs(approxVF(x_cv)-y_cv); header{6} = 'Error_VF';


%% Szegö
opts=init_opts();
[Mean, Var, Var_real, Var_imag, crit_opt, model] = CplxGPapprox('Szego', xi, yi, x_cv, opts);%, [-5; -1], [5;5]);%,[],[],[],0,[1, 1e-3]);
alpha_Szego = model.param(2)*1e4
plot_cplxfun(x_cv, Mean, ['Szego'], 'b:');
plot_cplxfun(x_cv, Mean-y_cv, 'Error Szegö', 'g-',  [], [], [], 100)
figure(1000)
semilogy(x_cv, abs(Mean-y_cv), 'g-', 'DisplayName', 'Szegö')
[RMSE_Szego, max_errorSzego] = compute_approx_error(Mean, y_cv, 'Szego');
export_data(:, 7) = abs(Mean); header{7} = 'Szego';
export_data(:, 8) = abs(Mean-y_cv); header{8} = 'Error_Szego';

%% Adaptive Approximation
adap_opts = init_adap_opts();
%opts.verbose=true;
adap_opts.verbose=true;
opts.n_restart=5;
[Mean,Var, Var_real, Var_imag,crit,adap_model,res, data] = AdapApprox('Szego', xi, yi, x_cv,opts, adap_opts);
alpha_hybrid = adap_model.param(2)*1e4
plot_cplxfun(x_cv, Mean, 'Adap Approx', '--');
plot_cplxfun(x_cv, Mean-y_cv, 'Error Adap', 'k-',  [], [], [], 100)
figure(1000)
semilogy(x_cv, abs(Mean-y_cv), 'k-', 'DisplayName', 'Adap Approx')
title('Error (Magnitude)')
legend;
export_data(:, 9) = abs(Mean); header{9} = 'Adap';
export_data(:, 10) = abs(Mean-y_cv); header{10} = 'Error_Adap';


[RMSE_Adap, max_errorAdap] = compute_approx_error(Mean, y_cv, 'Adap');
for i = 1:length(data)
    compute_approx_error(data{i}.Mean, y_cv, ['Model with ' num2str(i-1) ' poles']);
end

for i = 1:length(data)
    data{i}.model.param(2)*1e4
end

export_csv('results/illustration_approx_circuit.csv', export_data, header);

