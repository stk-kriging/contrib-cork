function [V, lm] = stk_lm_diff (lm, x, diff)

assert (lm.tune_poles);

x = double (x);
assert (size (x, 2) == 2);
K = lm.n_poles;

if (diff < 1) || (diff > 2*K)
    stk_error ('Incorrect value of the diff argument', 'InvalidArgument');
end

pole_idx = mod (diff, K);
if pole_idx == 0
    pole_idx = K;
end

pole = lm.poles(pole_idx);

idx_r = logical(~x(:,end));  % Indices of real part data
idx_i = logical( x(:,end));  % Indices of imag part data

% Initialize derivative of design matrix
V = zeros (size (x, 1), 2 + 2*K);

xr = x(idx_r, 1);
xi = x(idx_i, 1);

% Derivative of complex basis function w.r.t. real part of pole
h_xr = 1 ./ ((xr - pole) .^ 2);
h_xi = 1 ./ ((xi - pole) .^ 2);

if diff > K
    % Derivative of complex basis function w.r.t. imaginary part of poles
    h_xr = 1i * h_xr;
    h_xi = 1i * h_xi;
end

V(idx_r, pole_idx) = real(h_xr);
V(idx_i, pole_idx) = imag(h_xi);
V(idx_r, pole_idx + K) = - imag (h_xr);
V(idx_i, pole_idx + K) =   real (h_xi);

if lm.use_frf_props

    % Derivative of complex basis functions w.r.t. real part of poles
    fpole = - conj (pole);
    h_xr = 1 ./ ((xr - fpole) .^ 2);
    h_xi = 1 ./ ((xi - fpole) .^ 2);

    if diff <= K  % diff of complex basis function w.r.t. real part of pole
        % Minus signs due to chain rule (pole is changed in opposite direction)
        h_xr = - h_xr;
        h_xi = - h_xi;
    elseif diff > K
        % Derivative of complex basis function w.r.t. imaginary part of poles
        h_xr = 1i * h_xr;
        h_xi = 1i * h_xi;
    end

    V(idx_r, pole_idx) = V(idx_r, pole_idx) - real (h_xr);
    V(idx_i, pole_idx) = V(idx_i, pole_idx) - imag (h_xi);
    V(idx_r, pole_idx + K) = V(idx_r, pole_idx + K) - imag(h_xr);
    V(idx_i, pole_idx + K) = V(idx_i, pole_idx + K) + real(h_xi);

end

if lm.use_zero_mean
    V = V(:,1:end-2);
end

end % function
