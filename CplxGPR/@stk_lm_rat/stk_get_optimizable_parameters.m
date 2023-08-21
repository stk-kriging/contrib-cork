function param = stk_get_optimizable_parameters (lm)

if lm.tune_poles
    param = lm.param;
else
    param=[];
end

end
