function dlogpdf = stk_distrib_logpdf_grad (distrib, z)

% FIXME: Get rid of this global variable
global CplxCov;
assert (CplxCov.n_param == 2 && CplxCov.sampling(2) == 'n')

assert (length (z) == 2);

alpha = z(2);

m = distrib.mu;
s = distrib.sigma;

dlogpdf = [0; - 1/alpha * (1 + (log(alpha) - m) / (s ^ 2))];

end % function
