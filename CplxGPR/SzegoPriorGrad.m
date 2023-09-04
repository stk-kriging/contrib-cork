% Log normal prior on alpha

function [dlogpdf] = SzegoPriorGrad(z,mu, sigma)

global CplxCov;
assert(CplxCov.n_param==2 && CplxCov.sampling(2)=='n')
assert(length(z)==2);
alpha=z(2);
dlogpdf = [0;-1/alpha-(log(alpha)-mu)/(sigma^2*alpha)];

end
