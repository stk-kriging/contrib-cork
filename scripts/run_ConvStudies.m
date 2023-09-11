%% Settings

% Load results from ./results/ if possible
% (set to false in order to force recomputation)
FORCE_RECOMPUTE = false;

% Use exact evaluations
% (set to a positive value for Gaussian noise)
NOISE_STD = 0;

% Select case study
if ~ exist ('CASE_NUM', 'var')
    CASE_NUM = 1;
end

% Default scale parameters (used for illustration only)
scale_x = 1;
scale_y = 1;

% Number of test points
% (this parameter is ignored for test problems with discrete data)
n_cv = 201;


%% Test cases

if CASE_NUM >= 6  % Common settings for the "parallel RLC circuits" case
    n_elements = 1000;
    xmin = 1;
    xmax = 2.5;
end

switch CASE_NUM

    case 1  % Vibro-acoustic benchmark
        fun_name = 'VibroAcoustics';
        f = @(ref_lev) fun_VibroAcoustics (ref_lev);
        Nz = 7:38;
        discrete_data = true;
        scale_x = 1e3;
        scale_y = 1e-7;
        gauss_noise = -30;

    case 2  % Spiral antenna
        fun_name = 'Spiral';
        f = @(ref_lev) fun_Spiral (ref_lev);
        Nz = 12:2:48;
        discrete_data = true;
        gauss_noise = -25;

    case 3  % Waveguide junction, S21 parameter
        fun_name = 'WGjunctionS21';
        f = @(ref_lev) fun_WGjunctionS21 (ref_lev);
        Nz = 4:14;
        discrete_data = true;
        gauss_noise = -25;

    case 4  % Waveguide junction, S41 parameter
        fun_name = 'WGjunctionS41';
        f = @(ref_lev) fun_WGjunctionS41 (ref_lev);
        Nz = 4:14;
        discrete_data = true;
        gauss_noise = -25;

    case 5  % PAC-MAN
        fun_name = 'PacmanRight';
        f = @(ref_lev) fun_pacmanRight (ref_lev);
        Nz = 1:9;
        discrete_data = true;
        scale_x = 1e3;
        gauss_noise = -30;

    case 6  % Parallel RLC circuits + dominant poles
        fun_name = 'CircuitDomPoles';
        f = @(omega) fun_Circuit (omega, n_elements, 1, 0.2, true);
        Nz = 20:2:60;
        discrete_data = false;
        gauss_noise = -20;
        nruns = 1;

    case 7  % Parallel RLC circuits
        fun_name = 'Circuit';
        f = @(omega) fun_Circuit (omega, n_elements, 1, 0.2, false);
        Nz = 20:2:60;
        discrete_data = false;
        gauss_noise = -20;
        nruns = 1;

    case 8  % Parallel RLC circuits + dominant poles (100 runs)
        fun_name = 'CircuitDomPoles100runs';
        f = @(omega, seed) fun_Circuit (omega, n_elements, seed, 0.2, true);
        Nz = 20:2:60;
        discrete_data = false;
        gauss_noise = -20;
        nruns = 100;

    case 9  % Parallel RLC circuits (100 runs)
        fun_name = 'Circuit100runs';
        f = @(omega, seed) fun_Circuit (omega, n_elements, seed, 0.2, false);
        Nz = 20:2:60;
        discrete_data = false;
        gauss_noise = -20;
        nruns = 100;
end


%% Illustrate function

if ~ contains (fun_name, 'Circuit')
    % (for the 'circuit' case, see draw_illustration_Circuit.m)

    [~, ~, x_cv, y_cv] = f(1);
    x_cv = scale_x * x_cv;
    y_cv = scale_y * y_cv;
    plot_cplxfun (x_cv, y_cv, 'Reference', 'k-')

    data = zeros (length (x_cv), 4);  header = {};
    data(:, 1) = x_cv;                header{1} = 'x';
    data(:, 2) = real (y_cv);         header{2} = 'y_ref_real';
    data(:, 3) = imag (y_cv);         header{3} = 'y_ref_imag';
    data(:, 4) = abs (y_cv);          header{4} = 'y_ref_abs';
    filename = fullfile ('results', ['illustration_' fun_name '.csv']);
    export_csv (filename, data, header);
end


%% List of methods

methods = {};
opts = init_opts();
adap_opts = init_adap_opts();

methods{end+1}.name = 'AAA';
methods{end}.function = @AAAapprox;

methods{end+1}.name = 'VF';
methods{end}.function = @VFapprox;

methods{end+1}.name = 'Szego';
methods{end}.function = @(xi, yi, x_cv) CplxGPapprox ('Szego', xi, yi, x_cv, opts);
methods{end}.style = 'gx--';

methods{end+1}.name = 'Adap';
methods{end}.function = @(xi, yi, x_cv) AdapApprox ('Szego', xi, yi, x_cv, opts, adap_opts);
methods{end}.style = 'mo-';

methods{end+1}.name = 'Gauss(Sep)';
methods{end}.function = @(xi, yi, x_cv) SepKrigingApprox ('stk_gausscov_iso', xi, yi, x_cv, [], gauss_noise);
methods{end}.style = 'o--';


%% Run convergence study

if discrete_data
    run_ConvStudy (methods, f, fun_name, Nz, FORCE_RECOMPUTE, discrete_data);
else
    run_ConvStudy (methods, f, fun_name, Nz, FORCE_RECOMPUTE, discrete_data, xmin, xmax, NOISE_STD, n_cv, nruns);
end

load (['results/' fun_name '_AdapFull.mat']);


%% Plot optimal model here...

figure (1);
semilogy (Nsz, squeeze (min (errorsRMSEfull, [], 3)), ...
    'go--', 'DisplayName', 'Optimal model');

figure (2);
semilogy (Nsz, squeeze (min (errorsMaxfull, [], 3)), ...
    'go--', 'DisplayName', 'Optimal model');
