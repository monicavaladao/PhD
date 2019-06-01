%> @file "@BlindKriging/BlindKriging.m"
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
%>	BlindKriging
%
% ======================================================================
%> @brief A blind kriging surrogate model
%>
%> Papers:
%> - "Blind Kriging: A New Method for Developing Metamodels",
%>   V.R. Joseph and Y. Hung and A. Sudjianto,
%>   ASME Journal of Mechanical Design, 2008
%> - "Functionally Induced Priors for the Analysis of Experiments",
%>   V.R. Joseph and J.D. Delaney,
%>   Technometrics, 2007
%>
%> Limitations:
%> - quartic is the highest order supported
% ======================================================================
classdef BlindKriging < Kriging

	properties (Access = private)
		% preprocessing values
		levels = []; %>< k level values
		polyScaling = [];

        % scaling array (orthogonal encoding)
        %> @todo update encoding code to make it cleaner. E.g., make use of logical indexing
        %encodingIdx = []; % logical indices (replaces repmat)
        %encodingFactors = []; % scaling factors
        
		%% L1 parameters
		idxTerms = []; %>< indices of chosen polynomial terms
		
		%> @brief Statistics
        %>
        %> Provides technical insight in the feature selection (not needed for fitting and/or predicting).
        stats = struct( ...
            'scores', [], ... % Cross-validated prediction errors
            'scoreIndex', [], ... % Chosen model index
            'scoreFinal', [], ... % Final score (after reoptimizing the parameters)
            'visitedDegrees', [] ... * considered terms
            );
	end

	% PUBLIC
	methods( Access = public )
		% ======================================================================
        %> @brief Class constructor
        %>
        %> Initializes the Blind kriging model. Takes the same parameters as @c Kriging
        %>
        %> @return instance of the blind kriging class
        % ======================================================================
		function this = BlindKriging(varargin)
            this = this@Kriging(varargin{:});
        end

		%% Function definitions (mostly getters)
		
		% ======================================================================
        %> @brief Returns some useful statistics
        %>
        %> @retval stats Statistics structure
        % ======================================================================
		function stats = getStatistics(this)
			stats = this.stats;
        end
        
 		%% Function declarations

		% ======================================================================
        %> @brief Fits a blind kriging model
        %>
        %> @param samples input sample matrix
        %> @param values output value matrix
        %> @retval IK The initial kriging model
        % ======================================================================
		[this IK] = fit(this, samples, values);
        
        % ======================================================================
        %> @brief Returns the regression function
        %>
        %> @param varargin Options
        %> @retval regressionFcn Degree matrix representing the regression function
        %> @retval expression Symbolic expression
        %> @retval terms Cell array of the individual terms
        % ======================================================================
		[regressionFcn expression terms] = regressionFunction(this,varargin);
	end % methods public    
    %% PROTECTED
    methods( Access = protected )
        %% blind kriging constructs special model matrix
        
        % ======================================================================
        %> @brief Constructs regression matrix
        %>
        %> @param points points matrix (optional)
        %> @retval F model matrix
        %> @retval dF derivative of the model matrix w.r.t. points or the hyperparameters
        % ======================================================================
		[F dF] = regressionMatrix(this, points);
    end % methods protected

    %% PRIVATE
	methods( Access = private )
        % ======================================================================
        %> @brief Returns coded model matrix
        %>
        %> @param samples input sample matrix
        %> @param m
        %> @param k
        %> @paramdelta
        %> @retval U coded model matrix
        %> @retval dU derivative of the coded model matrix w.r.t. points or the hyperparameters
        % ======================================================================
		[U dU] = polynomialCoding( this, samples, m, k, delta )

		% ======================================================================
        %> @brief Calculates the posterior of the beta coefficients
        %>
        %> @param R correlation matrix
        %> @param U coded model matrix
        %> @retval beta Estimated beta coefficients
        % ======================================================================
		beta = posteriorBeta(this, R, U);
		
		% ======================================================================
        %> @brief Posterior correlation matrix of the beta coefficients
        %>
        %> @param usedIdx
        %> @retval R correlation matrix
        % ======================================================================
		R = Rmatrix(this, usedIdx);
	end % methods private
    
    methods( Static )
        % ======================================================================
        %> @brief Returns a default options structure
        %>
        %> Blind kriging specific options:
        %> @code
        %>  options.regressionMetric = 'cvpe'; % metric to guide the feature selection phase
        %>  options.retuneParameters = false; % retune parameters after every BK step
        %>  options.RmatrixThreshold = 250; % when to use full matrix R or when to approximate by using sparse diagonal of R
        %>  options.regressionMaxOrder = 2; % maximum order of candidate feature to consider (quadratic)
        %> @endcode
        %> @retval options Options structure
        % ======================================================================
        function options = getDefaultOptions()
            
            options = BasicGaussianProcess.getDefaultOptions();
            
            % extend with blind kriging options
            options.regressionMetric = 'cvpe'; % metric to guide the feature selection phase
            options.retuneParameters = false; % retune parameters after every BK step
            options.RmatrixThreshold = 250; % when to use full matrix R or when to approximate by using sparse diagonal of R
            options.regressionMaxOrder = 2; % maximum order of candidate feature to consider (quadratic)
        end         
    end % methods static
end % classdef
