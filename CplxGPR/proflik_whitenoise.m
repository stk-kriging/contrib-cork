function C = proflik_whitenoise (model, xi, zi, optimize, draw_plots)

if nargin < 4
    optimize = true;
end
if nargin < 5
    draw_plots = false;
end

[xi, zi] = mapCplxData (xi, zi, false);

% Replace the original kernel with a white noise kernel
model.param = make_ComplexCov ('WhiteNoise');

% Compute profiled sigma^2
sigma2 = compute_profiled_sigma2 (model, xi, zi);
model.param.sigma2 = sigma2;

Cgls = stk_param_proflik (model, xi, zi);

if draw_plots
    figure (1)
    hz = linspace (-1e-3, 1e-3);
    Cz = zeros (size (hz));
    for i = 1:(length (hz))
        model.param.sigma2 = sigma2 + hz(i);
        Cz(i) = stk_param_proflik (model, xi, zi);
    end

    plot(hz, Cz);
    hold on;
    plot(0, Cgls, 'x');
    xlabel('Delta')
    ylabel('C')
end

if optimize
    [sigma2, C] = fminsearch (@(sigma2) ...
        goal_fun( sigma2, model, xi, zi), sigma2);
    if draw_plots
        plot (sigma2 - sigma2, C, 'o');
    end
    assert (C <= Cgls);
else
    C = Cgls;
end

end % function


function C = goal_fun (sigma2,model, xi, zi)

model.param.sigma2 = sigma2;
C = stk_param_proflik (model, xi, zi);

end % function
