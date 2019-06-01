function EI = srgtsExpectedImprovement(yPBS, yhat, sigma)
%Function srgtsExpectedImprovement computes the expected improvement,
%E[I(x)], at a point x given the present best solution, yPBS. Formally,
%E[I(x)] is defined:
% 
% E[I(x)] = (yPBS - yhat).*PHI( (yPBS - yhat)/sigma ) +
%           sigma.*phi( (yPBS - yhat)/sigma )
% 
% where:
%     * yhat and sigma are the prediction and square root of the prediction
%     variance given by the surrogate of the actual function at the point
%     x, respectively.
%     * PHI and phi are the cummulative distribution function and the
%     probability distribution function of the Gaussian process yhat.
% 
%Thus, for example:
%     EI = srgtsExpectedImprovement(yPBS, yhat, sigma): given the present
%     best solution, yPBS, returns the expected improvement of the vector
%     of predicted values, yhat, with square root of the prediction
%     variance, sigma.
%
%Example:
%     % basic information about the problem
%     designspace = [0;     % lower bound
%                    1]; % upper bound
%
%     % create a DOE
%     npoints = 4;
%     X = linspace(designspace(1), designspace(2), npoints)';
%
%     % evaluate analysis function at X points
%     Y = ((X.*6-2).^2).*sin((X.*6-2).*2); % this is an user-defined function
%     yT = -4;
%
%     % fit surrogate models
%     options   = srgtsKRGSetOptions(X, Y);
%     surrogate = srgtsKRGFit(options);
%
%     % create points
%     npointstest = 101;
%     Xxp = linspace(designspace(1), designspace(2), npointstest)';
%
%     % simulate surrogates at Xtest
%     [Yhat PredVar] = srgtsKRGPredictor(Xxp, surrogate);
%     sigma = sqrt(PredVar);
%     EI = srgtsExpectedImprovement(yT, Yhat, sigma);
%
%     subplot(2,1,1)
%     plot(X, Y, 'o', Xxp, Yhat); legend('data', 'yhat')
%     subplot(2,1,2)
%     plot(Xxp, EI); legend('expected improvement')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Felipe A. C. Viana
% felipeacviana@gmail.com
% http://sites.google.com/site/felipeacviana
%
% This program is free software; you can redistribute it and/or
% modify it. This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% run
u  = (yPBS - yhat)./sigma;
EI = (yPBS - yhat).*normcdf(u, 0, 1) + sigma.*normpdf(u, 0, 1);

return
