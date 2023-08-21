function [prior] = setSzegoPrior(mode, sigma)
    if nargin<2
        mode=0.1;
        sigma=3;
    end
    prior.mu=sigma^2+log(mode);
    prior.sigma = sigma;
    
    prior.HasCustomPriorDistribution=true;
    prior.eval_logpdf_prior = @(z) SzegoPrior(z, prior.mu, prior.sigma);
    prior.eval_logpdf_grad_prior = @(z) SzegoPriorGrad(z,prior.mu, prior.sigma);
end