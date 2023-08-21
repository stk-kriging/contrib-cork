%% Test complex 1D example
clf; close all; clear;

%% Function to approximate
for dom_poles = [false, true]
    n_elements=1000;
    n_cv=201;
    xmin=1; xmax=2.5; 
    f = @(omega) fun_Circuit(omega,n_elements, 1, 0.2, dom_poles);
    fun_name=['Circuit']; 
    if dom_poles
        fun_name = [fun_name 'DomPoles'];
    end

    %% Illustrate function:
    x_cv = sort([linspace(xmin,xmax,n_cv), 1.4142-2e-2:1e-4:1.4142+2e-2, 2.2361-2e-2:1e-4:2.2361+2e-2])';
    [y_cv, a, r, ~] = f(x_cv);
    % Complex conjugate poles and residues:
    a = [a, conj(a)]; r = [r, conj(r)];
    x_cv = 1e4*x_cv;
    plot_cplxfun(x_cv,y_cv, 'Reference', 'k-')
    data = zeros(length(x_cv), 4); header = {};
    data(:, 1) = x_cv; header{1} = 'x';
    data(:, 2) = real(y_cv); header{2} = 'y_ref_real';
    data(:, 3) = imag(y_cv); header{3} = 'y_ref_imag';
    data(:, 4) = abs(y_cv); header{4} = 'y_ref_abs';
    filename = ['results/illustration_' fun_name '.csv'];
    export_csv(filename, data, header);
    figure(5)
    subplot(1,2,1)
    plot(a, 'x')
    xlim([-1000,0])
    ylim([-1e5, 1e5])
    title('Distribution of poles')
    subplot(1,2,2)
    plot(r, 'x')
    title('Distribution of residues')
    if ~dom_poles
        data = [real(a); imag(a); real(r); imag(r)]';
        export_csv('results/Circuit_VF_representation.csv', data, 'Poles_Re, Poles_Im, Residues_Re, Residues_Im')
    else
        idx = [n_elements+1:n_elements+2, 2*n_elements+3:2*n_elements+4];
        data = [real(a(idx)); imag(a(idx)); real(r(idx)); imag(r(idx))]';
        export_csv('results/Circuit_VF_representation_DomPoles.csv', data, 'Poles_Re, Poles_Im, Residues_Re, Residues_Im')
    end
end