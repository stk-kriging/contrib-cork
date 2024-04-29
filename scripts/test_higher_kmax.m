%% Test using an increased maximum number of poles pairs.
clf; close all; clear;

%% Function to approximate (either function or training+test-data)
f = @(omega) fun_Circuit(omega, 1000, 1,0.2, true); xmin=1; xmax=2.5; fun='Circuit'; 

%% Training points:
n_training_points = 50;
xi = linspace(xmin, xmax, n_training_points)';
yi = f(xi);

%% Test points
n_cv = 201;
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


opts = init_opts();
opts.n_restart=5;
adap_opts = init_adap_opts();

%% Adaptive Approximations
models = {};
max_errz = [];
rmse_z = [];
n_poles = [];

kmax_z = 0:15;
for kmax = kmax_z
    disp(kmax)

    if (kmax==0)
        [Mean, Var, Var_real, Var_imag, crit_opt, model] = CplxGPapprox('Szego', xi, yi, x_cv, opts);
         n_poles = [n_poles 0];
    else
        adap_opts.pole_init_method.max_poles = kmax;
        adap_opts.max_poles=kmax;
        [Mean,Var, Var_real, Var_imag,crit,adap_model,res, data] = AdapApprox('Szego', xi, yi, x_cv,opts, adap_opts);
        n_poles = [n_poles length(get_lm_poles(adap_model.lm))];
    end
    
    [rmse, max_err] = compute_approx_error(Mean, y_cv);
    
    rmse_z = [rmse_z rmse]
    max_errz = [max_errz max_err]
end


figure;
plot(kmax_z, rmse_z, '*--', 'DisplayName', 'RMSE')
hold on;
plot(kmax_z, max_errz, '*--', 'DisplayName', 'MaxErr')
plot(kmax_z, n_poles, 'xk:', 'DisplayName', 'Chosen number of pole pairs')
xlabel('Max number of pole pairs.')
grid;
legend;

data_export = zeros(length(kmax_z), 4); header={};
data_export(:, 1) = kmax_z; header{1}='max_num_pole_pairs';
data_export(:, 2) = rmse_z; header{2}='rmse';
data_export(:, 3) = max_errz; header{3}='max_err';
data_export(:, 4) = n_poles; header{4}='chosen_num_pole_pairs';
export_csv('results/error_circuit_approx_different_max_pole_pairs.csv', data_export, header);
