function [xi, yi, x_cv, y_cv] = fun_pacmanRight(refinementlevel)

load('data_pacmanRight.mat')
xi = data{refinementlevel}.f/1000;
yi = transpose(data{refinementlevel}.S);
x_cv = data{end}.f/1000;
y_cv = transpose(data{end}.S);

end