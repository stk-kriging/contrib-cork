function [RMSE, max_error] = compute_approx_error(Approx, y_cv, verbose)
    if nargin <3
        verbose=0;
    end
    max_error = max(abs(Approx-y_cv));
    RMSE = sqrt(mean(abs(Approx-y_cv).^2));
    if verbose
        fprintf('Method: %s. RMSE: %f. Max Error: %f\n', verbose, RMSE, max_error)
    end
end

