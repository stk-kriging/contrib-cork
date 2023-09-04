function run_ConvStudy(methods, f, fun_name, Nz, recompute, discrete_data, xmin, xmax, noise_std, n_cv,nruns)

if discrete_data && nargin <8
    xmin=NaN;
    xmax=NaN;
    noise_std=0;
end

if nargin <10

    n_cv = 201;
end

if nargin <11
    nruns=1;
end

for i = 1:length(methods)
    name = [fun_name '_' methods{i}.name];
    fname = ['results/' name '.mat'];
    if isfile(fname)&&~recompute
        load(fname)
        if min(size(errorsRMSE))>1
            errorsRMSE_Median = median(errorsRMSE,2);
            errorsMax_Median = median(errorsMax,2);
            errorsRMSE = mean(errorsRMSE,2);
            errorsMax = mean(errorsMax,2);
        end
    else
        if isfield(methods{i}, 'Nz')
            Nz_m = methods{i}.Nz;
        else
            Nz_m = Nz;
        end
        if nruns>1
            [errorsRMSE, errorsMax, Nsz, errorsRMSE_Median, errorsMax_Median] = ConvStudy(f, Nz_m,methods{i}.function, name, discrete_data, xmin, xmax, noise_std, n_cv,nruns);

        else
            [errorsRMSE, errorsMax, Nsz] = ConvStudy(f, Nz_m,methods{i}.function, name, discrete_data, xmin, xmax, noise_std, n_cv,nruns);
        end
    end

    % Plot Results:
    if isfield(methods{i}, 'style')
        ls = methods{i}.style;
    else
        ls = 'x-';
    end
    figure(1)
    semilogy(Nsz, errorsRMSE, ls, 'DisplayName', methods{i}.name)
    hold on;
    title(fun_name)
    xlabel('Number of training points')
    ylabel('RMSE')
    legend;
    figure(2)
    semilogy(Nsz, errorsMax, ls, 'DisplayName', methods{i}.name)
    hold on;
    title(fun_name)
    xlabel('Number of training points')
    ylabel('Maximum error')
    legend;
    drawnow;
    if nruns>1
        figure(3)
        semilogy(Nsz, errorsRMSE_Median, ls, 'DisplayName', methods{i}.name)
        hold on;
        title(fun_name)
        xlabel('Number of training points')
        ylabel('RMSE - Median')
        legend;
        figure(4)
        semilogy(Nsz, errorsMax_Median, ls, 'DisplayName', methods{i}.name)
        hold on;
        title(fun_name)
        xlabel('Number of training points')
        ylabel('Maximum error - Median')
        legend;
        drawnow;
    end
end

end
