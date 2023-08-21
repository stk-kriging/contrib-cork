function lm = stk_set_optimizable_parameters (lm, param)

assert(lm.tune_poles);
% FIXME: Check input size and type
assert (all(lm.param_min <= param) && all(param <= lm.param_max));

lm.param = param;
lm.poles = param(1:lm.n_poles)+1i*param(lm.n_poles+1:end);

end 
