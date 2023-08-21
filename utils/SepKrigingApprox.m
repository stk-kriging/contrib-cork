function [Mean, Var, Var_real, Var_imag] = SepKrigingApprox(covfun, xi, yi, x_cv, poles, dim, lnv)
    if nargin <5
        poles = [];
    end
    if nargin <6
        dim=1;
    end
    if nargin <7
        lnv=-40;
    end
    model = stk_model (covfun, dim);
    model.lognoisevariance = lnv;
    if ~isempty(poles)
        basis=@(x) [ones(length(x),1), real(1./(x-transpose(poles))),-imag(1./(x-transpose(poles)))];
        model.lm = basis;
    end
    model.lm=stk_lm_null;
    %param1 = stk_param_estim(model, xi, real(yi))
    %param2 = stk_param_estim(model, xi, imag(yi))
    SurKriging_real = stk_predict (model, xi, real(yi), x_cv);
    SurKriging_imag = stk_predict(model, xi, imag(yi), x_cv);
    Mean = SurKriging_real.mean+1j*SurKriging_imag.mean;
    Var_real = SurKriging_real.var;
    Var_imag = SurKriging_imag.var;
    Var = Var_real+Var_imag;
end

