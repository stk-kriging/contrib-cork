function lm = stk_lm_rat (poles, tune_poles, pole_bounds, use_frf_props, use_zero_mean)

assert(iscolumn(poles));

if nargin <2
    tune_poles = false;
end

if nargin <3
    pole_bounds = [];
end

if nargin<4
    use_frf_props=false;
end

if nargin<5
    use_zero_mean=true;
end

if isempty(pole_bounds)
    pole_bounds = [-inf*ones(2*length(poles),1), inf*ones(2*length(poles),1)];
else
    assert(all(pole_bounds(:,1) <= pole_bounds(:,2)));
end

lm = struct (                    ...
    'n_poles',            length(poles), ...
    'poles',              poles, ...
    'param',              [real(poles);imag(poles)], ...
    'param_min',          pole_bounds(:,1),  ...
    'param_max',          pole_bounds(:,2), ...
    'tune_poles',         tune_poles, ...
    'use_frf_props',      use_frf_props, ...
    'use_zero_mean',      use_zero_mean);


lm = class (lm, 'stk_lm_rat', stk_lm_ ());

end

