% Log normal prior on alpha

function [logpdf] = SzegoPrior(z, mu, sigma)

    global CplxCov;
    assert(CplxCov.n_param==2 && CplxCov.sampling(2)=='n')
    assert(length(z)==2);
    alpha=z(2);
    logpdf = -log(alpha*sigma*sqrt(2*pi))-(log(alpha)-mu).^2/(2*sigma^2);
    
end

