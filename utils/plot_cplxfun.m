function [outputArg1,outputArg2] = plot_cplxfun(x,y,DisplayName, LineStyle, Var_real, Var_imag, Confidence_Color, figidx)

if nargin <3
    DisplayName='Unknown';
end
if nargin<4
    LineStyle='-';
end
if nargin <5
    Var_real = [];
    Var_imag =[];
end

if nargin<7 || isempty(Confidence_Color)
    Confidence_Color = [0.9, 0.9, 0.9];
end
if nargin <8
    figidx=11;
end


figure(figidx)
subplot(1,2,1)
hold on;
plot(x, real(y), LineStyle, 'DisplayName', DisplayName, 'LineWidth', 2)
xlabel('y')
title('Real part')
legend;
subplot(1,2,2)
hold on;
plot(x, imag(y), LineStyle, 'DisplayName', DisplayName, 'LineWidth', 2)
xlabel('y')
legend;
title('Imag part')
%sgtitle('Complex function')

if nargin>4 &&~isempty(Var_real)
    % Plot confidence intervals
    subplot(1,2,1)
    xx = [x; flipud(x)];
    zz = [real(y) - 2.575829*sqrt(abs(Var_real)); flipud(real(y) + 2.575829*sqrt(abs (Var_real)))];
    %Remark SurKriging_real.var agrees well with SurKriging_cplx.var(1:n_cv)
    h_axes=gca();
    ci= fill(h_axes, xx', zz', Confidence_Color, 'EdgeColor', Confidence_Color, 'DisplayName', ['99% Confidence Interval (' DisplayName ')']);
    uistack(ci, 'bottom')
    subplot(1,2,2)
    xx = [x; flipud(x)];
    zz = [imag(y) - 2.575829*sqrt(abs(Var_imag)); flipud(imag(y) + 2.575829*sqrt(abs (Var_imag)))];
    h_axes=gca();
    ci= fill(h_axes, xx', zz', Confidence_Color, 'EdgeColor', Confidence_Color, 'DisplayName', ['99% Confidence Interval (' DisplayName ')']);
    uistack(ci, 'bottom')
end

figure(figidx+1)
hold on;
plot(x, abs(y), LineStyle, 'DisplayName', DisplayName, 'LineWidth', 2)
if nargin>4 &&~isempty(Var_real)
    xx = [x; flipud(x)];
    zz = [abs(y) - 2.575829*sqrt(Var_real+Var_imag); flipud(abs(y) + 2.575829*sqrt(Var_real+Var_imag))];
    h_axes=gca();
    ci= fill(h_axes, xx', zz', Confidence_Color, 'EdgeColor', Confidence_Color, 'DisplayName', ['99% Conf.-Int.  (' DisplayName ')']);
    uistack(ci, 'bottom')
end
title('Magnitude')
xlabel('y')
legend;


end

