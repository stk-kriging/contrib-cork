function [opts] = init_opts()

opts.p0=[]; % starting value for kernel hyper-parameter tuning
opts.tune_poles=false;
opts.poles=[]; % (initial) poles
opts.lb=[]; % lower bounds for tuning
opts.ub=[]; % upper bounds for tuning
opts.lnv = -inf;
opts.n_restart=20; % number of restarts for tuning (multistart)
opts.params=[]; % kernel hyper-parameter (empty-> tuning)
opts.verbose=false;
opts.pole_bounds=[]; % bounds for tuning of poles (empty -> defaults based on training data)
opts.use_frf_props=true; % use real/complex GP if omega=0 is involved; use pole pairs in rational model
opts.use_zero_mean=true;
opts.SzegoPrior = [1;3]; % Lognormal prior with mode=1*(w_max-w_min) and sigma=3 (only for Szegö kernel)
opts.tune_kernel_first=true;

end
