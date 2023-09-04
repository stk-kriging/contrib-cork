%% Test complex 1D example
clf; close all; clear;

%% Function to approximate
f = @(omega)fun_LowOrderRational(omega);xmin =0; xmax=1;

if 1
    fun_name=['LowOrderRat1'];
else
    fun_name=['LowOrderRat2'];
    f = @(omega) 1j*f(omega);
end

discrete_data  = false;
recompute =true;
noise_std = 0;
Nz = 4:2:30;

%% Illustrate function:
n_cv=201;
x_cv = linspace(xmin,xmax,n_cv)';
y_cv = f(x_cv);
plot_cplxfun(x_cv,y_cv, 'Reference', 'k-')
data = zeros(n_cv, 4); header = {};
data(:, 1) = x_cv; header{1} = 'x';
data(:, 2) = real(y_cv); header{2} = 'y_ref_real';
data(:, 3) = imag(y_cv); header{3} = 'y_ref_imag';
data(:, 4) = abs(y_cv); header{4} = 'y_ref_abs';
filename = ['results/illustration_' fun_name '.csv'];
export_csv(filename, data, header);

%% Convergence study
methods={}; % Initialize

opts = init_opts();
opts.verbose=true;
methods{end+1}.name = 'Szego';
methods{end}.function = @(xi, yi, x_cv)  CplxGPapprox('Szego', xi, yi, x_cv, opts);
methods{end}.style='x--';

methods{end+1}.name = 'Szego0P'
opts.use_frf_props=false;
methods{end}.function = @(xi, yi, x_cv)  CplxGPapprox('Szego0P', xi, yi, x_cv, opts);
methods{end}.style='x--';

methods{end+1}.name='Gauss(Sep)';
methods{end}.function=@(xi,yi,x_cv) SepKrigingApprox('stk_gausscov_iso', xi, yi, x_cv, [], -20);

methods{end+1}.name='Chebyshev';
methods{end}.function = @Polyapprox;

run_ConvStudy(methods, f, fun_name, Nz, recompute, discrete_data,  xmin, xmax, noise_std);
