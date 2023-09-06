function logpdf = stk_distrib_logpdf (distrib, z)

% FIXME: Get rid of this global variable
global CplxCov;
assert (CplxCov.n_param == 2 && CplxCov.sampling(2) == 'n')

assert (length (z) == 2);

la = log (z(2));  % log (alpha)

m = distrib.mu;
s = distrib.sigma;
C = -0.91893853320467266;  % - log (sqrt (2 * pi)) in double precision

% Logpdf on the lognormal distribution on alpha
logpdf = C - la - log (s) - ((la - m) .^ 2) / (2 * s^2);

end % function
