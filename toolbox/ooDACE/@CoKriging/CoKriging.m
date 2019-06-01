%> @file "@CoKriging/CoKriging.m"
%> @authors Ivo Couckuyt
%> @version 1.4 ($Revision$)
%> @date $LastChangedDate$
%> @date Copyright 2010-2013
%>
%> This file is part of the ooDACE toolbox
%> and you can redistribute it and/or modify it under the terms of the
%> GNU Affero General Public License version 3 as published by the
%> Free Software Foundation.  With the additional provision that a commercial
%> license must be purchased if the ooDACE toolbox is used, modified, or extended
%> in a commercial setting. For details see the included LICENSE.txt file.
%> When referring to the ooDACE toolbox please make reference to the corresponding
%> publications:
%>   - Blind Kriging: Implementation and performance analysis
%>     I. Couckuyt, A. Forrester, D. Gorissen, F. De Turck, T. Dhaene,
%>     Advances in Engineering Software,
%>     Vol. 49, pp. 1-13, July 2012.
%>   - Surrogate-based infill optimization applied to electromagnetic problems
%>     I. Couckuyt, F. Declercq, T. Dhaene, H. Rogier, L. Knockaert,
%>     International Journal of RF and Microwave Computer-Aided Engineering (RFMiCAE),
%>     Special Issue on Advances in Design Optimization of Microwave/RF Circuits and Systems,
%>     Vol. 20, No. 5, pp. 492-501, September 2010. 
%>
%> Contact : ivo.couckuyt@ugent.be - http://sumo.intec.ugent.be/?q=ooDACE
%> Signature
%>	CoKriging
%
% ======================================================================
%> @brief A cokriging surrogate model
%>
%> Papers:
%> - "Bayesian Analysis of Computer Code Outputs"
%>   M. Kennedy, A. O'Hagan, N. Higgins (2001)
%> - "Multi-fidelity optimization via surrogate modelling"
%>   A.I.J Forrester, A. Sobester, A.J. Keane (2007)
%>
%> Limitations:
%> - Supports 2 fidelity datasets
%> - Likelihood function doesn't support gradients
%>
%> @todo Generalize to an arbitrary number of (multi-fidelity) datasets
% ======================================================================
classdef CoKriging < BasicGaussianProcess

	properties (Access = private)
        
        % Sub-Gaussian Processes (one for each dataset)
        GP = [];
		
        % preprocessing values
        nrSamples = []; %>< array of number of samples
		idxDataset = []; %>< indices to samples/values to get only dataset row i
	end

	% PUBLIC
	methods( Access = public )

		% CTor
		function this = CoKriging(varargin)
            this = this@BasicGaussianProcess(varargin{:});
            
            % warn the user early if something is not possible
            if this.optimIdx(1,this.SIGMA2)
               error('Including sigma2 in the optimization process is not possible with cokriging.'); 
            end
		end % constructor

		%% Function definitions (mostly getters)
        
		% ======================================================================
        %> @brief Returns samples of dataset t
        %>
        %> @param t index of dataset to retrieve
        %> @retval samples samples of dataset t
        % ======================================================================
		function samples = getSamplesIdx(this, t)
            samples = this.getSamples();
            samples = samples(this.idxDataset(t,1):this.idxDataset(t,2),:);
        end
        
        % ======================================================================
        %> @brief Returns values of dataset t
        %>
        %> @param t index of dataset to retrieve
        %> @retval values values of dataset t
        % ======================================================================
		function values = getValuesIdx(this,t)
            values = this.getValues();
            values = values(this.idxDataset(t,1):this.idxDataset(t,2),:);
        end
		        
		%% Function declarations

		% ======================================================================
        %> @brief Fits a gaussian process for multi-fidelity datasets
        %>
        %> @param samples input sample matrix (cell array)
        %> @param values output value matrix (cell array)
        % ======================================================================
		this = fit(this, samples, values);
        
		% ======================================================================
        %> @brief Returns the regression function
        %>
        %> @param varargin Options
        %> @retval regressionFcn Degree matrix representing the regression function
        %> @retval expression Symbolic expression
        %> @retval terms Cell array of the individual terms
        % ======================================================================
		[regressionFcn expression terms] = regressionFunction(this,varargin);
        
        % ======================================================================
        %> @brief Returns the internal correlation function handle
        %>        
        %> @param varargin Options
        %> @retval correlationFcn String of correlation function
		[correlationFcn expression] = correlationFunction(this,varargin);

	end % methods public
    
    %% PROTECTED (needed by @KrigingModel of SUMO toolbox)
    methods( Access = protected )
		
        %% Cokriging constructs custom correlation and regression matrices
        % and treats samples/values different (as cell array instead of numeric array)
        
        % ======================================================================
        %> @brief Sets samples and values matrix
        %>
        %> @param samples input sample matrix (cell array)
        %> @param values  output value matrix (cell array)
        % ======================================================================
        this = setData(this, samples, values);
        
        % ======================================================================
        %> @brief Constructs extrinsic correlation matrix
        %>
        %> @param points1 input point matrix (optional)
        %> @param points2 input point matrix (optional)
        %> @retval psi Correlation matrix
        %> @retval dpsi Derivative of correlation matrix w.r.t. the hyperparameters
        % ======================================================================
		[psi dpsi] = extrinsicCorrelationMatrix(this, points1, points2);
        
        % ======================================================================
        %> @brief Constructs intrinsic covariance matrix (stochastic kriging/regression kriging)
        %>
        %> @param points1 input point matrix (optional)
        %> @param points2 input point matrix (optional)
        %> @retval psi Covariance matrix
        %> @retval dpsi Derivative of covariance matrix w.r.t. the hyperparameters OR the input points
        % ======================================================================
		[Sigma dSigma] = intrinsicCovarianceMatrix(this, points1, points2);
        
        % ======================================================================
        %> @brief Constructs regression matrix
        %>
        %> @param points input point matrix (optional)
        %> @retval F Model matrix
        %> @retval dF Derivative of model matrix w.r.t. the hyperparameters OR the input points
		[F dF] = regressionMatrix(this, points);
    end % methods protected

    %% PRIVATE
	methods( Access = private )
	end % methods private
    
    methods( Static )

        % ======================================================================
        %> @brief Returns a default options structure
        %>
        %> @retval options Options structure
        % ======================================================================
        function options = getDefaultOptions()
            options = Kriging.getDefaultOptions();

            % We can optional choose another optimizer for each sub-Kriging
            % model
            %optimopts.GradObj = 'on';
            %optimopts.DerivativeCheck = 'on';
            %optimopts.Diagnostics = 'on';
            %optimopts.Algorithm = 'active-set';
            %optimopts.MaxFunEvals = 1000;
            %optimopts.MaxIter = 500;
            %optimopts.TolX = eps; % 1e-15;
            %optimopts.TolFun = eps; %1e-15;
            %options.hpOptimizer = {options.hpOptimizer MatlabOptimizer( 1, 1, optimopts )};

            % enable rho for cokriging
            options.rho0 = 5; % initial scaling factor between datasets
            options.rhoBounds = [0.1 ; 5]; % scaling factor optimization bounds
        end
    end % methods static
end % classdef
