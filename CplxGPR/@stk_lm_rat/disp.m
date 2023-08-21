function disp (lm)

fprintf ('<%s>\n', stk_sprintf_sizetype (lm));

loose_spacing = stk_disp_isloose ();

if loose_spacing
    fprintf ('|\n');
end

fprintf ('|%i complex poles: ', lm.n_poles*(1+lm.use_frf_props));
for i = 1:lm.n_poles
    fprintf('%g+%gi  ', real(lm.poles(i)), imag(lm.poles(i)));
    if lm.use_frf_props
        fprintf('%g+%gi  ', -real(lm.poles(i)), imag(lm.poles(i)));
    end
end
if lm.tune_poles
    fprintf('\n| Pole Tuning enabled')
else
    fprintf('\n| Pole Tuning disabled')
end

if lm.use_zero_mean
    fprintf('\n| Model uses a zero-mean')
else
    fprintf('\n| Model uses a non-zero mean\n')
end

if loose_spacing
    fprintf ('\n|\n');
end

end % function
