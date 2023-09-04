function [lb, ub] = stk_param_getdefaultbounds (lm, xi, zi)

if lm.tune_poles
    lb = lm.param_min;
    ub = lm.param_max;
else
    lb=[];
    ub=[];
end

end
