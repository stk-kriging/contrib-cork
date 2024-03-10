%% Study values of alpha for different real parts of the poles of the lower order rational function
clf; close all; clear;

alpha_i = [0.05, 0.1, 0.15, 0.2, 0.25];
alpha_est = [];
alpha_est_without_sym_cond = [];

colors = 'rgbmkcy';
n_cv = 201;
xmin = 0; xmax = 1;
x_cv = linspace(xmin,xmax,n_cv)';

export_data = zeros(n_cv, 2*length(alpha_i)+1); header = {};
export_data(:, 1) = x_cv; header{1} = 'x';

for i = 1:length(alpha_i)
  f = @(omega)fun_LowOrderRational(omega, alpha_i(i)); 

  xi = linspace(xmin, xmax, 20)';
  yi = f(xi);
  y_cv = f(x_cv);
  
  export_data(:, 1+2*i) = real(y_cv); header{1+2*i} = ['y_real_alpha' num2str(alpha_i(i))];
  export_data(:, 2+2*i) = imag(y_cv); header{2+2*i} = ['y_imag_alpha' num2str(alpha_i(i))];

  opts = init_opts();
  [~, ~, ~, ~, ~, SzegoSymModel] = CplxGPapprox('Szego', xi, yi, x_cv, opts);
  alpha_est = [alpha_est, SzegoSymModel.param(2)];
  plot_cplxfun(x_cv,y_cv, ['alpha=' num2str(alpha_i(i))], colors(i))

  [~, ~, ~, ~, ~, SzegoNoSymModel] = CplxGPapprox('Szego0P', xi, yi, x_cv, opts);
  alpha_est_without_sym_cond = [alpha_est_without_sym_cond, SzegoNoSymModel.param(2)];

end

export_csv('results/illustration_rational_functions.csv', export_data, header);

export_data = zeros(length(alpha_i), 3); header = {};
export_data(:, 1) = alpha_i; header{1} = 'alpha';
export_data(:, 2) = alpha_est; header{2} = 'alpha_est_PCov';
export_data(:, 3) = alpha_est_without_sym_cond; header{3} = 'alpha_est_NoPCov';
export_csv('results/alpha_estimation.csv', export_data, header);

figure;
plot(alpha_i, alpha_est, 'k*--')
hold on
plot(alpha_i, alpha_est_without_sym_cond, 'bx--')

xlabel('Real part of poles of low order rational function')
ylabel('Estimated value of alpha')
title('Szego-kernel based Approximations based on 20 equidistant training points')
legend('With PCov / Sym', 'Without PCov / Sym')

%% Study value of alpha for circuit without/with dominant poles
f_without_dom_poles = @(omega) fun_Circuit(omega, 1000, 1, 0.2, false);
f_with_dom_poles = @(omega) fun_Circuit(omega, 1000, 1, 0.2, true);
xmin=1; xmax=2.5; fun='Circuit';
xi = linspace(xmin, xmax, 50)';
yi_without_dominant_poles = f_without_dom_poles(xi);
yi_with_dominant_poles = f_with_dom_poles(xi);
n_cv = 201;
x_cv = linspace(xmin,xmax,n_cv)';
opts = init_opts();
[~, ~, ~, ~, ~, SzegoSymModel_without_dominant_poles] = CplxGPapprox('Szego', xi, yi_without_dominant_poles, x_cv, opts);
[~, ~, ~, ~, ~, SzegoSymModel_with_dominant_poles] = CplxGPapprox('Szego', xi, yi_with_dominant_poles, x_cv, opts);

alpha_without_dominant_poles = SzegoSymModel_without_dominant_poles.param(2)*1e4

alpha_with_dominant_poles = SzegoSymModel_with_dominant_poles.param(2)*1e4
