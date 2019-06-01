function PI = srgtsProbOfImprovement(yT, yhat, sigma)
%Function srgtsProbOfImprovement computes the probability of improvement
%Pr[Y <= yT] (probability that Y is bellow a target yT). Formally,
%Pr[Y <= yT] is defined:
% 
% Pr[Y <= yT] = PHI( (yT - yhat)/sigma )
% 
% where yhat and sigma are the prediction and square root of the prediction
% variance given by the surrogate of the actual function at the point x;
% and PHI is the cummulative distribution function of the Gaussian
% distribution.
% 
%Thus, for example:
%     PI = srgtsProbOfImprovement(YT, YHAT, SIGMA): given the target YT
%     returns the probability of improvement of the vector of predicted
%     values YHAT with square root of the prediction variance SIGMA.
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
%     PI = srgtsProbOfImprovement(yT, Yhat, sigma);
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
PI = normcdf((yT - yhat)./sigma, 0, 1);

return
