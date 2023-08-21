function [xi, yi, x_cv, y_cv] = fun_VBA(refinementlevel)
    load('data_VibroAcoustics.mat')
    xi = data{refinementlevel}.freq'/1000;
    yi = 1e7*(data{refinementlevel}.real+1i*data{refinementlevel}.imag);
    x_cv = data{end}.freq'/1000;
    y_cv = 1e7*(data{end}.real +1i*data{end}.imag);
end

