function approx = VFapprox(xi, yi, x_cv, N)
    if nargin<4
        approxVF = VectorFitting(xi,yi);
    else
        approxVF = VectorFitting(xi, yi, N);
    end
    approx = approxVF(x_cv);
end

