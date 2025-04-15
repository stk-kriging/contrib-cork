classdef ComplexCov

    properties
        Cov;
        PCov;
        rescaling;
        dCov;
        dPCov;
        ana_derivatives;
        n_param;
        lb;
        ub;
        lnv;
        param_init_fun;
        dim;
        sampling;
    end

    methods
        function obj = ComplexCov(Cov, PCov, n_param, rescaling, sampling, dCov, dPCov)
            %COMPLEXCOV Construct an instance of this class
            %   Detailed explanation goes here
            obj.Cov = Cov;
            obj.PCov = PCov;
            obj.n_param=n_param;
            obj.lnv=-inf;
            obj.lb=[];
            obj.ub=[];
            obj.param_init_fun=@(varargin) zeros(n_param,1);
            obj.dim=1;
            if nargin <4
                obj.rescaling='eeeeeeeee';
            else
                obj.rescaling = rescaling;
            end
            if nargin<5
                obj.sampling='nnnnnnnnnn';
            else
                obj.sampling=sampling;
            end
            if nargin <6
                obj.ana_derivatives=false;
            else
                obj.ana_derivatives=true;
                obj.dCov=dCov;
                obj.dPCov = dPCov;
            end
        end

        function obj = set_bounds(obj,lb, ub)
            obj.lb = lb;
            obj.ub = ub;
        end

        function [lb,ub] = get_bounds (obj, param0, xi, zi)  %#ok<INUSD>

            % This method is called from stk_complexcov_getdefaultbounds
            % with raw (not rescaled) parameters

            if isempty (obj.lb) && isempty (obj.ub)
                % These bounds appear to be suitable only for logified
                % positive parameters (i.e., assuming rescaling 'e' for all
                % parameters).
                lb = param0 - 5;
                ub = param0 + 5;
            else
                lb = obj.lb;
                ub = obj.ub;
            end
        end

        function obj = set_random_param (obj)
            assert(~isempty(obj.lb)&&~isempty(obj.ub));
            p0 =zeros(obj.n_param,1);
            for i = 1:obj.n_param
                if obj.sampling(i)=='n'
                    p0(i) = rescale(rand(), obj.lb(i), obj.ub(i), 'InputMin',0, 'InputMax', 1);
                elseif obj.sampling(i)=='l'
                    L_lb = log(obj.lb(i)); L_ub = log(obj.ub(i));
                    p0(i) = exp(L_lb+(L_ub-L_lb)*rand());
                else
                    stk_error('sampling option not implemented\n')
                end
            end
            obj = stk_set_optimizable_parameters (obj, p0);
        end

        function [obj] = set_params_init (obj, param0, lnv)
            obj.param_init_fun = @(varargin) param0;
            obj.lnv = lnv;
        end

        function [obj] = set_params_init_fun(obj,fun)
            obj.param_init_fun=fun;
        end

        function [param0, lnv]  = get_params_init(obj, varargin)
            if nargin<2
                param0 = obj.param_init_fun();
            else
                if length(varargin)==2
                    param0 = obj.param_init_fun(varargin{:});
                else
                    stk_error('Error during parameter initialization\n')
                end

            end
            lnv = obj.lnv;
        end

        function K = CovMat(obj, param, x,y,pairwise, diff)

            % Here, `param` is expected to contained rescaled parameters
            % (wherever rescaling is indeed necessary)

            if nargin < 6
                diff = -1;
            end
            assert(size(x,2)==2);

            x_idx_r = logical(~x(:,end));  % Indices of real part data
            x_idx_i = logical( x(:,end));  % Indices of imag part data
            y_idx_r = logical(~y(:,end));
            y_idx_i = logical( y(:,end));

            xr = x(x_idx_r, 1);
            xi = x(x_idx_i, 1);
            yr = y(y_idx_r, 1);
            yi = y(y_idx_i, 1);
            if pairwise
                assert(size(x,1)==size(y,1));
                K=zeros(size(x,1),1);
                if diff<1
                    K(x_idx_r) = 1/2*real(obj.Cov(xr,yr, param)+obj.PCov(xr,yr, param));%j=j'=0
                    K(x_idx_i) =  1/2*real(obj.Cov(xi,yi, param)-obj.PCov(xi,yi, param));%j=j'=1
                else
                    K(x_idx_r) = 1/2*real(obj.dCov{diff}(xr,yr, param)+obj.dPCov{diff}(xr,yr, param));%j=j'=0
                    K(x_idx_i) =  1/2*real(obj.dCov{diff}(xi,yi, param)-obj.dPCov{diff}(xi,yi, param));%j=j'=1
                end
            else
                yr=yr';
                yi=yi';
                K=zeros(size(x,1), size(y,1));
                if diff <1
                    K(x_idx_r, y_idx_r) = 1/2*real(obj.Cov(xr,yr, param)+obj.PCov(xr,yr, param));%j=j'=0
                    K(x_idx_i, y_idx_i) = 1/2*real(obj.Cov(xi,yi,param)-obj.PCov(xi,yi, param));%j=j'=1
                    K(x_idx_r, y_idx_i) = 1/2*imag(-obj.Cov(xr,yi,param)+obj.PCov(xr,yi,param)); %
                    K(x_idx_i, y_idx_r) = 1/2*imag(obj.Cov(xi,yr, param)+obj.PCov(xi,yr, param)); % j=1, j'=0
                else
                    K(x_idx_r, y_idx_r) = 1/2*real(obj.dCov{diff}(xr,yr, param)+obj.dPCov{diff}(xr,yr, param));%j=j'=0
                    K(x_idx_i, y_idx_i) = 1/2*real(obj.dCov{diff}(xi,yi,param)-obj.dPCov{diff}(xi,yi, param));%j=j'=1
                    K(x_idx_r, y_idx_i) = 1/2*imag(-obj.dCov{diff}(xr,yi,param)+obj.dPCov{diff}(xr,yi,param)); %
                    K(x_idx_i, y_idx_r) = 1/2*imag(obj.dCov{diff}(xi,yr, param)+obj.dPCov{diff}(xi,yr, param)); % j=1, j'=0
                end
            end
        end

    end
end
