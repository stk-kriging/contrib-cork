%% Test complex 1D example
clf; close all; clear;

%% Function to approximate (either function or training+test-data)
f = @(ref_level) fun_VibroAcoustics(ref_level); fun='VibroAcoustics';

%% Training and test points;
ref_level=18; % (Refinement level for training points)
[xi, yi, x_cv, y_cv] = f(ref_level);
[x_cv,idx] = sort([x_cv;xi]);
y_cv = [y_cv; yi];
y_cv = y_cv(idx);
[x_cv,idx] = unique(x_cv);
y_cv = y_cv(idx);
n_training_points = length(xi);

export_csv('results/model_selection_issue_trainingdata.csv', [1e3*xi, 1e-7*real(yi), 1e-7*imag(yi)], 'x,y_real, y_imag');

data_cv = zeros(length(x_cv),10);
data_cv(:,10) = x_cv*1e3; header_cv{10} = 'x';
data_cv(:,1) = 1e-7*real(y_cv); header_cv{1} = 'ref_real';
data_cv(:,2) = 1e-7*imag(y_cv); header_cv{2} = 'ref_imag';
data_cv(:,3) = abs(1e7*y_cv);  header_cv{3} = 'ref_abs';

%% Illustrate function:
plot_cplxfun(x_cv,y_cv, 'Reference', 'k-')
plot_cplxfun(xi, yi, 'Data for Fitting', 'kx')

%% Szegö
opts=init_opts();
%opts.SzegoPrior = [1;2];
[Mean, Var, Var_real, Var_imag, crit_opt, model] = CplxGPapprox('Szego', xi, yi, x_cv, opts);%, [-5; -1], [5;5]);%,[],[],[],0,[1, 1e-3]);
plot_cplxfun(x_cv, Mean, ['Szego'], 'b:');
[RMSE_Szego, max_errorSzego] = compute_approx_error(Mean, y_cv, 'Szego');


%% Adaptive Approximation
adap_opts = init_adap_opts();
adap_opts.verbose=true;
[Mean,Var, Var_real, Var_imag,crit,adap_model_loo_stab,res, data,  opt_idx_stab] = AdapApprox('Szego', xi, yi, x_cv,opts, adap_opts);
plot_cplxfun(x_cv, Mean, 'Adap Approx', '--');
[RMSE_Adap, max_errorAdap] = compute_approx_error(Mean, y_cv, 'Adap');



%% Adaptive Approximation Loo
adap_opts = init_adap_opts();
adap_opts.verbose=true;
adap_opts.pole_init_method.name='equi';
adap_opts.model_selection.lambdaz = [1 0]; adap_opts.model_selection.normalize=0; % Set LOO
[Mean,Var, Var_real, Var_imag,crit,adap_model_loo,res, data,  opt_idx] = AdapApprox('Szego', xi, yi, x_cv,opts, adap_opts);
plot_cplxfun(x_cv, Mean, 'Adap Approx', '--');
[RMSE_Adap, max_errorAdap] = compute_approx_error(Mean, y_cv, 'Adap');



[eps, res2, res2Loo, res2Penalty, loo_plot_data] = loo_res(xi,yi,adap_model_loo, true, true,[1,0.2], 0, 1);
figure(3);
subplot(1,3,1)
plot(loo_plot_data.x_cv, real(loo_plot_data.ref_pred), 'k-', 'DisplayName', 'Model-Pred');
legend;
title('Real part')
hold on;
subplot(1,3,2)
plot(loo_plot_data.x_cv, imag(loo_plot_data.ref_pred), 'k-', 'DisplayName', 'Model-Pred');
legend;
title('Imag part')
hold on;
subplot(1,3,3)
plot(loo_plot_data.x_cv, abs(loo_plot_data.ref_pred), 'k-', 'DisplayName', 'Model-Pred');
legend;
title('Abs')
hold on;
drawnow;
for i = 1:length(loo_plot_data.predz)
    subplot(1,3,1)
    plot(loo_plot_data.x_cv, real(loo_plot_data.predz{i}), '--',  'DisplayName', ['LooModel - ' num2str(i)])
    subplot(1,3,2)
    plot(loo_plot_data.x_cv, imag(loo_plot_data.predz{i}), '--', 'DisplayName', ['LooModel - ' num2str(i)]);
    subplot(1,3,3)
    plot(loo_plot_data.x_cv, abs(loo_plot_data.predz{i}), '--', 'DisplayName', ['LooModel - ' num2str(i)]);
end

for i = 1:length(data)
    compute_approx_error(data{i}.Mean, y_cv, ['Model with ' num2str(i-1) ' poles']);
end

data_cv(:,4) = 1e-7*real(data{3}.Mean); header_cv{4}='opt_real';
data_cv(:,5) = 1e-7*imag(data{3}.Mean); header_cv{5}='opt_imag';
data_cv(:,6) = abs(1e-7*data{3}.Mean);  header_cv{6}='opt_abs';

data_cv(:,7) = 1e-7*real(Mean); header_cv{7}='loo_real';
data_cv(:,8) = 1e-7*imag(Mean); header_cv{8}='loo_imag';
data_cv(:,9) = abs(1e-7*Mean); header_cv{9}='loo_abs';
export_csv('results/model_selection_issue_approximations.csv', data_cv, header_cv);

data_loo = zeros(length(loo_plot_data.x_cv), 3*(n_training_points+1)+1);
data_loo(:,1) = 1e-7*real(loo_plot_data.ref_pred); header_loo{1}='ref_real';
data_loo(:,2) = 1e-7*imag(loo_plot_data.ref_pred); header_loo{2}='ref_imag';
data_loo(:,3) = abs(1e-7*loo_plot_data.ref_pred);  header_loo{3}='ref_abs';
for i = 1:length(loo_plot_data.predz)
    data_loo(:,1+3*i) = 1e-7*real(loo_plot_data.predz{i}); header_loo{1+3*i}=['loo_pred' num2str(i) '_real'];
    data_loo(:,2+3*i) = 1e-7*imag(loo_plot_data.predz{i}); header_loo{2+3*i}=['loo_pred' num2str(i) '_imag'];
    data_loo(:,3+3*i) = abs(1e-7*loo_plot_data.predz{i});  header_loo{3+3*i}=['loo_pred' num2str(i) '_abs'];
end
data_loo(:,end) = 1e3*loo_plot_data.x_cv; header_loo{size(data_loo,2)} = 'x';
export_csv('results/model_selection_issue_loo_predictions.csv', data_loo, header_loo);

%% Evaluate model on finer grid than x_cv
[x_cv_new] = unique(sort([x_cv;linspace(4.5, 4.54)']));
Mean_new = CplxPrediction(xi,yi,x_cv_new, adap_model_loo, opts.use_frf_props);
plot_cplxfun(x_cv_new, Mean_new, 'fine');
export_csv('results/model_selection_issue_approximationFine.csv', [1e3*x_cv_new, 1e-7*real(Mean_new), 1e-7*imag(Mean_new), abs(1e-7*Mean_new)], 'x, loo_real, loo_imag, loo_abs');
