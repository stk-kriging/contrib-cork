function [approx] = AAAapprox(xi, yi, x_cv)
    [approxAAA] = aaa(yi,xi);
    approx=approxAAA(x_cv);
end

