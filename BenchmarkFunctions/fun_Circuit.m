function [F, a, r, F2] = fun_Circuit(DKomega, n_elements, seed, Rvar, Rdom)

assert(size(DKomega,2)==1)
if nargin <2
    n_elements=500;
end
if nargin<3
    seed=1;
end

if nargin<4
    Rvar=0.2;
end

if nargin<5
    Rdom=false;
end


omega = 1e4*DKomega;
rng(seed)


Li = rescale(rand(1,n_elements), .1e-3, 2e-3, 'InputMin',0, 'InputMax',1);

Ci = rescale(rand(1,n_elements), 1e-6,20e-6, 'InputMin',0, 'InputMax',1);

Ri = Li*1000.*(1+rescale(rand(1,n_elements), -Rvar, Rvar, 'InputMin', 0, 'InputMax', 1));

if Rdom
    Li = [Li, 1e-3];
    Ci = [Ci, 5e-6];
    Ri = [Ri, 1e-1];
    Li = [Li, 1e-3];
    Ci = [Ci, 2e-6];
    Ri = [Ri, 1e-1];
end


assert(all(Ri/2*sqrt(Ci/Li)<1))

s=1i*omega;
F = sum(s./(s.^2.*Li+s.*Ri+1./Ci),2);

if nargout >1
    a = -Ri./(2*Li)+1i*sqrt(1./(Li.*Ci)-(Ri./(2*Li)).^2);
    r = (sqrt(1./(Li.*Ci)-(Ri./(2*Li)).^2) +Ri./(2*Li)*1i)./(2*Li.*sqrt(1./(Li.*Ci)-(Ri./(2*Li)).^2));
    F2= sum([r, conj(r)].*1./(1i*omega-([a,conj(a)])),2);
end

end
