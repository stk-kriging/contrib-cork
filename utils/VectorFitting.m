% Approximate Mapping from input omega to complex output y using using vector fitting
function [Surrogate, poles] = VectorFitting(omega,y,N)

if iscolumn(omega)
    w=transpose(omega);
else 
    w=omega;
end
if iscolumn(y)
    f=transpose(y);
else
    f=y;
end

if nargin<3 || N==Inf
    N=length(w)-1;
    if mod(N,2)~=0
        N=N-1;
    end
end

if mod(N,2)~=0
    error('Please specify even order')
end


% Parameters:
Ns=length(w);
Niter=30; % Iterations of Vector fitting (Pole reallocation)
%Initial poles for Vector Fitting:
%Complex starting poles :
bet=linspace(w(1),w(Ns),N/2);
poles=zeros(1, 2*length(bet));
for n=1:length(bet)
  alf=-bet(n)*1e-2;
  poles(2*n-1:2*n)=[(alf-1i*bet(n)) (alf+1i*bet(n)) ]; 
end

weight=ones(1,Ns); %All frequency points are given equal weight
opts.relax=1;      %Use vector fitting with relaxed non-triviality constraint
opts.stable=1;     %Enforce stable poles
opts.asymp=2;      %Include only D in fitting    
opts.skip_pole=0;  %Do NOT skip pole identification
opts.skip_res=1;   %Skip identification of residues (C,D,E) (up to last iteration..)
opts.cmplx_ss=1;   %Create complex state space model
opts.spy2=0;       %Do NOT create magnitude plot for fitting of f(s) 


for iter =1:Niter
    if iter ==Niter
        opts.skip_res=0;
    end
    [SER,poles,rmserr,fit]=vectfit3(f,1i*w,poles,weight,opts);
end

Surrogate = @(x) arrayfun(@(y) SER.C*(1i*y*eye(size(SER.A))-SER.A)^(-1)*SER.B+SER.D+1i*y*SER.E, x);
end

