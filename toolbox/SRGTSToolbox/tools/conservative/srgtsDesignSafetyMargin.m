function [sm eRMS loss] = srgtsDesignSafetyMargin(targetconservativeness, errors)
%Function srgtsDesignSafetyMargin designs the safety margin for a
%conservative surrogate given a vector of target conservativeness. A
%conservative estimation yc is obtained by adding the safety marging sm to
%the unbiased prediction yhat
%
% yc = yhat + sm;
%
%Thus, for example:
%
%     SM = srgtsDesignSafetyMargin(TC, ERRORS): returns SM, a vector of
%     safety margin designed with the vector of target conservativeness,
%     TC, and the error matrix, ERROR. It is very important to notice that
%     here:
%
%     ERROR = Yhat - Ytrue;
%
%     where Ytrue is the actual value of the function.
%
%     ERRORS can be obtained with test points or or alternatively by cross
%     validation via srgtsCrossValidation.
%
%     [SM eRMS] = srgtsDesignSafetyMargin(...): also returns the estimator
%     of the root mean square error (eRMS) based on the input errors and
%     the calculated safety margin. If one is using cross-validation
%     errors, eRMS will in fact be the PRESSRMS value.
%
%     [SM eRMS LOSS] = srgtsDesignSafetyMargin(...): also returns the
%     estimator of the loss in accuracy due to the safety margin:
%
%     LOSS = 100*(eRMS/eRMSref - 1)
%
%     where eRMSref is the root mean square error without adding any safety
%     margin.
%
%Example:
%     % basic information about the problem
%     myFN = @cos; % this could be any user-defined function
%     designspace = [0;     % lower bound
%                    2*pi]; % upper bound
%
%     % create DOE
%     nbpoints = 5;
%     X = linspace(designspace(1), designspace(2), nbpoints)';
%     Y = feval(myFN, X);
%
%     % fit kriging model
%     srgtOPT  = srgtsKRGSetOptions(X, Y);
%
%     % calculate cross validation errors, and PRESSRMS
%     [PRESSRMS, eXV] = srgtsCrossValidation(srgtOPT)
%
%     PRESSRMS =
%
%     1.1465
%
%     XVERRORS =
%
%     1.5700
%    -0.8006
%     0.6003
%    -0.8006
%     1.5700
%
%     % compute safety margin for target conservativeness of 95%
%     TC = 95;
%     [SM PRESSRMS loss] = srgtsDesignSafetyMargin(TC, eXV)
%     SM =
%
%     0.8006
%
%     PRESSRMS =
%
%     1.6249
%
%     loss =
%
%     41.7306

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
% design safety margin based on the empirical CDF of the errors
eRMS0 = sqrt(mean(errors.^2));
nbtc  = length(targetconservativeness);

[F,X] = ecdf(errors);
x     = 1 - targetconservativeness/100;
sm    = x; % just memory allocation
eRMS  = x;
loss  = x;
for c1 = 1 : nbtc
    idx = find(F <= x(c1)); idx = idx(end);
    sm(c1) = -X(idx);
    
    e = errors + sm(c1);
    eRMS(c1) = sqrt(mean(e.^2));
    loss(c1) = 100*(eRMS(c1)/eRMS0 - 1);
end

return
