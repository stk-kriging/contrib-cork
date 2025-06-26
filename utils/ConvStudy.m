function [errorsRMSE, errorsMax, Nsz, errorsRMSE_Median, errorsMax_Median] = ConvStudy(f,Nz, method,name, discrete, xmin, xmax, noise_std, n_cv, Nruns)
    if nargin <5
        discrete=false;
    end
    if nargin<8
        noise_std=0;
    end
    if nargin<9
        n_cv=201;
    end
    if nargin <10
        Nruns=1;
    end

    Nsz=zeros(size(Nz));
    errorsRMSE = zeros(length(Nz),Nruns);
    errorsMax = zeros(length(Nz), Nruns);
    if endsWith_ (name, 'Adap')
        errorsRMSEfull = NaN(length(Nz), Nruns, 15);
        errorsMaxfull = NaN(length(Nz), Nruns,15);
    end

    for j = 1:Nruns

    %% Test points
    if ~discrete
        x_cv = linspace(xmin,xmax,n_cv)';
       if Nruns==1
       y_cv = f(x_cv);
       else
           y_cv = f(x_cv, j);
       end
    else
        [~,~, x_cv, y_cv] = f(1);
    end

    %% Convergence Study
    for i=1:length(Nz)
        tic;

        %% Training points:
        if ~discrete
            xi = linspace(xmin,xmax,Nz(i))';
            if Nruns==1
                yi = f(xi);
            else
                yi = f(xi, j);
            end
            rng(23)
            yi = yi+ noise_std*(randn(size(xi))+1i*randn(size(xi)));
        else
            ref_level=Nz(i); % (Refinement level for training points)
            [xi, yi, ~,~] = f(ref_level);
        end
        Nsz(i)=length(xi);
       % try
            if endsWith_ (name, 'Adap')
                [Approx, ~, ~, ~, ~, ~, ~, data,~] = method(xi, yi, x_cv);
                for k = 1:length(data)
                    [errorsRMSEfull(i,j,k), errorsMaxfull(i,j,k)] = compute_approx_error(data{k}.Mean, y_cv);
                end
            elseif endsWith_ (name, 'Chebyshev')
                xc = cos((2*(1:Nz(i))-1)/2/Nz(i)*pi)'; % Chebyshev nodes
                xc = (xmax-xmin)/2*xc+(xmax+xmin)/2; % Scale and shift
                if Nruns ==1
                    yc=f(xc);
                else
                    yc = f(xc, j);
                end
                Approx=method(xc, yc, x_cv);
            else
                Approx = method(xi, yi, x_cv);
            end
     %   catch
     %       Approx = method(xi, yi, x_cv,j); %% Very, very ugly workaround for fully adaptive approximation
      %  end

        [errorsRMSE(i,j), errorsMax(i,j)] = compute_approx_error(Approx, y_cv, name);

        fprintf('Approximation: %s. Run %i of %i. Repetition %i of %i. Evaluation took %f s.\n', name, i, length(Nz),j, Nruns, toc);
    end
    end

    if nargout>3
         errorsRMSE_Median = median(errorsRMSE,2);
         errorsMax_Median = median(errorsMax,2);
    end

    %% Store results
    save(['results/' name '.mat'], 'errorsRMSE', 'errorsMax', 'Nsz');
    if endsWith_ (name, 'Adap')
        save(['results/' name 'Full.mat'], 'errorsRMSE', 'errorsMax', 'Nsz', 'errorsRMSEfull', 'errorsMaxfull');
    end

    errorsRMSE = mean(errorsRMSE,2);
    errorsMax = mean(errorsMax,2);
    data = zeros(length(Nsz),3);
    data(:,1) = Nsz;
    data(:,2) = errorsRMSE;
    data(:,3) = errorsMax;
    header = 'N, RMSE, Max';
    export_csv(['results/' name '.csv'], data, header);

end


function b = endsWith_ (s, t)

L = length (t);
b = ((length (s)) >= L) && (strcmp (s((end-L+1):end), t));

end
