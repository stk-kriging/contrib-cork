function [xi, yi, x_cv, y_cv] = fun_taperS11(refinementlevel)
    load('data_Spiral.mat')
    xi = data{refinementlevel}.f;%(21:end);
    yi = data{refinementlevel}.S;%(21:end));
    x_cv = data{end}.f;%(105:end);
    y_cv = data{end}.S;%(105:end));
end

