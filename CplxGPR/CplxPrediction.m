function [Mean,  Var, Var_real, Var_imag] = CplxPrediction(xi, yi, x_cv, model, use_frf_props)
   [xi_cplx, yi_cplx] = mapCplxData(xi, yi, use_frf_props);
   [x_cv_cplx] = mapCplxData(x_cv, [], false);
   n_cv = size(x_cv,1);
   SurKriging_cplx=stk_predict(model, xi_cplx, yi_cplx, x_cv_cplx);
   Mean = SurKriging_cplx.mean(1:n_cv)+1j*SurKriging_cplx.mean(n_cv+1:2*n_cv);
   if nargout >1
       Var_real = SurKriging_cplx.var(1:n_cv);
       Var_imag = SurKriging_cplx.var(n_cv+1:2*n_cv);
       Var = Var_real+Var_imag;
   end
end

