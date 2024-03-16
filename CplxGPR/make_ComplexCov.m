% make_ComplexCov is a wrapper around the constructor of ComplexCov
%
% Append '0P' for not including the "FRF" Pcov function

function CplxCov = make_ComplexCov (model)

if all(model(end-1:end)=='0P')
    model = model(1:end-2);
    zeroPCov=true;
else
    zeroPCov=false;
end

dCov={};
dPCov={};
rescaling='eeeeee'; % Rescaling per parameter (e=exponential, n=none)
sampling='nnnnnnn'; % Normal sampling vs logarithmic sampling for restarts
lb=[];
ub=[];
p0=[];
lnv0=-inf;
switch model
    case 'SLS'
        Cov = @(x,y,p) p(1) .* (2*p(2)+1i*(x-y))./((p(2)-1i*y).*(p(2)+1i*x).*(p(2)+1i*(x-y)));
        PCov = @(x,y,params) (Cov(x,-y, params));
        %             dCov{1} = @(x,y,p) Cov(x,y,[1,p(2)]);
        %             dPCov{1} = @(x,y,p) PCov(x,y,[1,p(2)]);
        %             dCov{2} = @(k,l,p) p(1)*-1i.*(p(2).*(p(2)+1i.*k).^(-1).*k.^(-1).*(p(2)+1i.*(k+(-1).*l)).^(-2)+k.^(-1).*(1i.*p(2)+l).^(-2)+(p(2)+1i.*k).^(-2).*(1i.*p(2)+(-1).*k+l).^(-1));
        %             dPCov{2} = @(x,y,p) dCov{2}(x,-y,p);
        rescaling = 'en';
        lb = [-15;1e-6];
        ub = [15;15];
        p0=[0; 1e-3];
        n_param=2;
    case 'Szego'
        Cov = @(x,y,params)  params(1)*1./(2*params(2)+1i*(x-y));
        PCov = @(x,y,params) Cov(x,-y, params);
        rescaling='en';
        sampling= 'nn';
        dCov{1}=@(x,y,params) Cov(x,y,[1,params(2)]);
        dPCov{1}=@(x,y,params) PCov(x,y,[1,params(2)]);
        dCov{2} = @(x,y,params) -2*params(1)*1./((2*params(2)+1i*(x-y)).^2);
        dPCov{2}=@(x,y,params) -2*params(1)*1./((2*params(2)+1i*(x+y)).^2);
        lb=[-15;1e-6];
        ub=[15; 1];
        p0=[0;1e-3];
        n_param=2;
    case 'LS'
        Kreal = @(x,y,params) (params*min(x,y));
        Cov = @(x,y,params) Kreal(x,y,params(1))+Kreal(x,y,params(2));
        PCov = @(x,y,params) Kreal(x,y,params(1))-Kreal(x,y,params(2));
        rescaling='ee';
        n_param=2;
    case 'QS'
        Kreal = @(s,t,params) params*(s.^3/30.*(10*t.^2-5.*s.*t+s.^2).*(s<=t)+t.^3/30.*(10*s.^2-5.*s.*t+t.^2).*(s>t));
        Cov = @(x,y,params) Kreal(x,y,params(1))+Kreal(x,y,params(2));
        PCov = @(x,y,params) Kreal(x,y,params(1))-Kreal(x,y,params(2));
        rescaling='ee';
        n_param=2;
    case 'SCS'
        Cov = @(x,y,p) (p(1)/2 .* (1./(3*p(2)+1j*(x-y))) .* ( (1./(2*p(2)-1j*y)) + (1./(2*p(2)+1j*x)) - (1./(3*(3*p(2)-1j*y))) - 1./(3*(3*p(2)+1j*x))));
        PCov = @(x,y,params) (Cov(x,-y, params));
        rescaling = 'en';
        lb = [-15;1e-6];
        ub = [15;15];
        p0=[0; 1e-3];
        n_param=2;
    case 'DC'
        Cov = @(x,y,params) (params(1)*(1./(params(3)+1j*(x-y)).*(1./(params(2)+params(3)/2+1j*x) +1./(params(2)+params(3)/2-1j*y))));
        PCov = @(x,y,params) (Cov(x,-y, params));
        rescaling = 'een';
        lb = [-15; -15; 1e-6];
        ub = [15; 15; 15];
        p0 = [0; 0; 1e-3];
        n_param=3;
    case 'CS'
        Kreal = @(s,t,params) params*(s.^2/2.*(t-s/3).*(s<=t)+t.^2/2.*(s-t/3).*(s>t));
        Cov = @(x,y,params) Kreal(x,y,params(1))+Kreal(x,y,params(2));
        PCov = @(x,y,params) Kreal(x,y,params(1))-Kreal(x,y,params(2));
        rescaling='ee';
        n_param=2;
    case 'SepGauss'
        Kgauss = @(x,y,params) (params(1)*exp(-(params(2)*(x-y)).^2));
        Cov = @(x,y,params) Kgauss(x,y,params(1:2))+Kgauss(x,y,params(3:4));
        PCov = @(x,y,params) Kgauss(x,y,params(1:2))-Kgauss(x,y,params(3:4));
        n_param=4;
        rescaling='eeee';
        lb = [-15;-15;-15;-15];
        ub = [15;15;15;15];
        p0=[0;0;0;0];
    case 'WhiteNoise'
        Cov = @(x,y,p) p*(x==y);
        PCov = @(x,y,p) zeros(size(Cov(x,y,p)));
        n_param=1;
        rescaling='n';
        lb = [0];
        ub = [1e5];
        p0=[1];
end

if zeroPCov
    PCov = @(x,y,params) (zeros(size(Cov(x,y,params))));
    for i =1:length(dPCov)
        dPCov{i} = @(x,y,params) (zeros(size(Cov(x,y,params))));
    end
end

if ~isempty(dCov)
    CplxCov = ComplexCov(Cov, PCov, n_param, rescaling, sampling, dCov, dPCov);
else
    CplxCov = ComplexCov(Cov, PCov,n_param, rescaling, sampling);
end

if ~isempty(lb)
    CplxCov = CplxCov.set_bounds(lb,ub);
end

if ~isempty(p0)
    CplxCov = CplxCov.set_params_init(p0, lnv0);
end

end