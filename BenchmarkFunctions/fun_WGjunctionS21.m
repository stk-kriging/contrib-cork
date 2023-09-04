function [xi, yi, x_cv, y_cv] = fun_WGjunctionS21(refinementlevel)

load('data_WGjunctionS21.mat')
xi = data{refinementlevel}.f;%(21:end);
yi = data{refinementlevel}.S;%(21:end));
x_cv = data{end}.f;%(105:end);
y_cv = data{end}.S;%(105:end));

end
