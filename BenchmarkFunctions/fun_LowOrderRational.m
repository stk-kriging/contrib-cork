function [res] = fun_LowOrderRational(omega)

res= 1./(1j*omega+0.1)+.5./(1j*omega-(-0.1-0.5i))+.5./(1j*omega-(-0.1+0.5i));

end
