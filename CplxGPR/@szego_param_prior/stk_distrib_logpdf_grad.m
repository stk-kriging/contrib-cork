function dlogpdf = stk_distrib_logpdf_grad (distrib, z)

assert (length (z) == 2);

alpha = z(2);

m = distrib.mu;
s = distrib.sigma;

dlogpdf = [0; - 1/alpha * (1 + (log(alpha) - m) / (s ^ 2))];

end % function
