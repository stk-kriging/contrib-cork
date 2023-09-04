function [V, lm] = stk_lm_diff (lm, x, diff)

assert(lm.tune_poles);

x = double (x);
assert (size(x,2)==2);
nx=size(x,1);
assert(diff<=2*lm.n_poles);

pole_idx = mod(diff, lm.n_poles);
if pole_idx==0
    pole_idx=lm.n_poles;
end

% Derivative of complex basis functions w.r.t. real part of poles
h_a = @(x) 1./(x-lm.poles(pole_idx)).^2;

idx_r = logical(~x(:,end));  % Indices of real part data
idx_i =  logical(x(:,end));  % Indices of imag part data

% Initialize derivative of design matrix
V=zeros(nx,2+2*lm.n_poles);

if diff <=lm.n_poles
    % Derivative of complex basis function w.r.t. real part of pole
    h_xr = h_a(x(idx_r,1));
    h_xi = h_a(x(idx_i,1));

elseif diff>lm.n_poles
    % Derivative of complex basis function w.r.t. imaginary part of poles
    h_b = @(x) 1i*h_a(x);
    h_xr = h_b(x(idx_r,1));
    h_xi = h_b(x(idx_i,1));
else
    stk_error ('Incorrect value of the diff argument', 'InvalidArgument');
end

V(idx_r,[pole_idx, pole_idx+lm.n_poles]) = [real(h_xr), -imag(h_xr)];
V(idx_i,[pole_idx, pole_idx+lm.n_poles]) = [imag(h_xi),  real(h_xi)];

if lm.use_frf_props

    % Derivative of complex basis functions w.r.t. real part of poles
    flipped_pole = -real(lm.poles(pole_idx))+1i*imag(lm.poles(pole_idx));
    h_a = @(x) 1./(x-flipped_pole).^2;

    if diff <=lm.n_poles  % diff of complex basis function w.r.t. real part of pole
        % Minus signs due to chain rule (pole is changed in opposite direction)
        h_xr = -h_a(x(idx_r,1));
        h_xi = -h_a(x(idx_i,1));

    elseif diff>lm.n_poles
        % Derivative of complex basis function w.r.t. imaginary part of poles
        h_b = @(x) 1i*h_a(x);
        h_xr = h_b(x(idx_r,1));
        h_xi = h_b(x(idx_i,1));
    end

    V(idx_r,[pole_idx, pole_idx+lm.n_poles]) = V(idx_r,[pole_idx, pole_idx+lm.n_poles])+[-real(h_xr), -imag(h_xr)];
    V(idx_i,[pole_idx, pole_idx+lm.n_poles]) = V(idx_i,[pole_idx, pole_idx+lm.n_poles])+[-imag(h_xi),  real(h_xi)];

end

if lm.use_zero_mean
    V = V(:,1:end-2);
end

end % function
