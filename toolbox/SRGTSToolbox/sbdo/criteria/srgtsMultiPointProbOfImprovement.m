function PI = srgtsMultiPointProbOfImprovement(yT, yhat, sigma)
%Function srgtsMultiPointProbOfImprovement computes the probability of
%improvement Pr[Y <= yT] (probability that Y is bellow a target yT) when
%multiple sites are added. Pr[Y <= yT] is an approximation that neglects
%the correlation between the points. It is computed as:
% 
% Pr[Y <= yT] = 1 - prod(1 - PHI( (yT - yhat)/sigma ))
% 
% where yhat and sigma are the prediction and square root of the prediction
% variance given by the surrogate of the actual function at the point x;
% and PHI is the cummulative distribution function of the Gaussian
% distribution.
% 
%Thus, for example:
%     PI = srgtsMultiPointProbOfImprovement(YT, YHAT, SIGMA): given the
%     target YT returns the probability of improvement if all points (in
%     the vector of YHAT) were added.
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
%     PI = srgtsMultiPointProbOfImprovement(yT, Yhat, sigma);
%
%     subplot(2,1,1)
%     plot(X, Y, 'o', Xxp, Yhat); legend('data', 'yhat')
%     subplot(2,1,2)
%     plot(Xxp, PI); legend('probability of improvement')

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
PI = 1 - prod(1 - srgtsProbOfImprovement(yT, yhat, sigma));

return
