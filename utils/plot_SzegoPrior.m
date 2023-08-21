function plot_SzegoPrior(params)

    mode=params(1);
    sigma=params(2);
    mu=sigma^2+log(mode);
    
    x = linspace(0,5*mode);
    Lognormalpdf = @(x) 1/(x*sigma*sqrt(2*pi))*exp(-(log(x)-mu)^2/(2*sigma^2));
    y = arrayfun(@(z)Lognormalpdf(z), x);
    subplot(1,2,1)
    plot(x,y, '--')
    xlabel('alpha')
    ylabel('PDF')
    subplot(1,2,2)
    x = exp(linspace(log(mode*1e-4),log(mode*1e4)));
    y = arrayfun(@(z)Lognormalpdf(z), x);
    semilogx(x,y, '--');
    xlabel('alpha')
    ylabel('PDF')
    sgtitle('Prior')
    
end

