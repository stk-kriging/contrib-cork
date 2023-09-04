function z = feval (lm, x)

x = double (x);
assert (size(x,2)==2);

nx=size(x,1);

h = @(x) 1./(x-transpose(lm.poles)); % Complex basis functions

idx_r = logical(~x(:,end));  % Indices of real part data
idx_i =  logical(x(:,end));  % Indices of imag part data

% Evaluate complex basis functions
h_xr = h(x(idx_r,1));
h_xi = h(x(idx_i,1));

% Initialize design matrix
z=zeros(nx,2*lm.n_poles);

z(idx_r,:) = [real(h_xr), -imag(h_xr)];
z(idx_i,:) = [imag(h_xi),  real(h_xi)];

if lm.use_frf_props
    flip_poles = -real(lm.poles)+1i*imag(lm.poles);
    h = @(x) 1./(x-transpose(flip_poles)); % Complex basis functions
    h_xr = h(x(idx_r,1));
    h_xi = h(x(idx_i,1));
    z(idx_r,:) =z(idx_r,:)+ [-real(h_xr), -imag(h_xr)];
    z(idx_i,:) =z(idx_i,:)+ [-imag(h_xi),  real(h_xi)];
end

if ~lm.use_zero_mean
    %% Unknown complex mean
    z(:,end+1:end+2) = [idx_r, idx_i];
end


end % function
