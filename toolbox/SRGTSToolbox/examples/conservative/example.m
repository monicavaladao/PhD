%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;
clear all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% basic information about the problem
myFN    = @sasena;  % this could be any user-defined function
myFNOPT = 2;

designspace = [0  0;  % lower bound
               5  5]; % upper bound

ndv = size(designspace, 2);

% create DOE
npoints = 12;
X = srgtsScaleVariable(srgtsDOETPLHS(npoints, ndv), ...
    [zeros(1, ndv); ones(1, ndv)], ...
    designspace);
Y = feval(myFN, X, myFNOPT);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fit kriging
srgtOPT  = srgtsKRGSetOptions(X, Y);
srgtSRGT = srgtsKRGFit(srgtOPT);

[PRESSRMS, eXV] = srgtsCrossValidation(srgtOPT);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% design safety margin
targetconservativeness = 95
sm = srgtsDesignSafetyMargin(targetconservativeness, eXV);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% checking how good the estimation of the safety margin was
Xtest = srgtsScaleVariable(srgtsDOEFullFactorial(ndv,21), ...
    [zeros(1, ndv); ones(1, ndv)], ...
    designspace);
Ytest = feval(myFN, Xtest, myFNOPT);
Yhat  = srgtsKRGEvaluate(Xtest, srgtSRGT);

% percent of the points that have positive (conservative) errors
Ekrg  = Yhat - Ytest;
Ec    = Ekrg + sm;
unbiasedconservativeness = 100*mean(Ekrg>0)
actualconservativeness   = 100*mean(Ec>0)
