%> @file "dacefit.m"
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
%>	[krige perf] = dacefit(samples, values, regr, corr, theta0, lb, ub )
%
% ======================================================================
%> @brief  Creates and fits a kriging model
%>
%> DACE toolbox compatible interface to ooDACE (wrapper)
%>
%> @param samples input sample matrix
%> @param values output value matrix
%> @param regr regression function (string)
%> @param corr correlation function (string)
%> @param theta0 initial hyperparameter values
%> @param lb lower bound of hyperparameters
%> @param ub upper bound of hyperparameters
%> @retval krige a ready-to-use kriging model
%> @retval perf a structure with some useful metrics
% ======================================================================
function  [krige perf] = dacefit(samples, values, regr, corr, theta0, lb, ub )

    if nargin == 0
        disp('Usage: [krige perf] = dacefit(samples, values, regr, corr, theta0, lb, ub )');
        return;
    end
    
    [n dim] = size(samples);

    opts = Kriging.getDefaultOptions();
    if nargin == 7
        opts.hpBounds = [lb ; ub];
        
        optimopts.GradObj = 'on';
        optimopts.DerivativeCheck = 'off';
        optimopts.Diagnostics = 'off';
        optimopts.Algorithm = 'active-set';
        opts.hpOptimizer = MatlabOptimizer( dim, 1, optimopts );
    end

    krige = Kriging( opts, theta0, regr, str2func(corr) );
    krige = krige.fit( samples, values );

    perf = struct( ...
        'regr', krige.regressionFunction(), ...
        'corr', krige.correlationFunction(), ...
        'theta', krige.getHyperparameters(), ...
        'beta', NaN, ... % not available
        'gamma', NaN, ... % not available
        'sigma2', krige.getProcessVariance(), ...
        'S', NaN, ...  % not available
        'Ssc', NaN, ... % not available
        'Ysc', NaN, ... % not available
        'C', NaN, ... % not available
        'Ft', NaN, ...  % not available
        'G', NaN ... % not available
    );

end
