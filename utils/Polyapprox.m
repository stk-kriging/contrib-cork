function [approx] = Polyapprox(xi, yi, x_cv)
    approx = barylag([xi,yi], x_cv);
end

