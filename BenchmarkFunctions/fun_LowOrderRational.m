function [res] = fun_LowOrderRational(omega, a)

if nargin < 2
  a = 0.1;
end


res= 1./(1j*omega+a)+.5./(1j*omega-(-a-0.5i))+.5./(1j*omega-(-a+0.5i));

end
