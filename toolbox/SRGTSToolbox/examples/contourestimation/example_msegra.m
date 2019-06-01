%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;
clear all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% basic information about the problem
myFN    = @braninhoo;  % this could be any user-defined function
myFNOPT = [];

designspace = [-5   0;  % lower bound
               10  15]; % upper bound

ndv = size(designspace, 2);

% create experimental design
npoints = 10;
X = srgtsScaleVariable(srgtsDOETPLHS(npoints, ndv), ...
    [zeros(1, ndv); ones(1, ndv)], ...
    designspace);
Y = feval(myFN, X);

% create test points
nlevels = 51;
Ptest = srgtsDOEFullFactorial(ndv, nlevels);
Xtest = srgtsScaleVariable(Ptest, [zeros(1, ndv); ones(1, ndv)], designspace);
Ytest = feval(myFN, Xtest);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% surrogates
srgtOPTKRG  = srgtsKRGSetOptions(X, Y);
srgtSRGTKRG = srgtsKRGFit(srgtOPTKRG);

Ykrg0  = srgtsKRGEvaluate(Xtest, srgtSRGTKRG);

% radial basis function
srgtOPTRBFmq  = srgtsRBFSetOptions(X, Y);
srgtSRGTRBFmq = srgtsRBFFit(srgtOPTRBFmq);

% shepard
srgtOPTSHEP  = srgtsSHEPSetOptions(X, Y);
srgtSRGTSHEP = srgtsSHEPFit(srgtOPTSHEP);

srgtOPTHelpers  = {srgtOPTRBFmq  srgtOPTSHEP};
srgtSRGTHelpers = {srgtSRGTRBFmq srgtSRGTSHEP};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MSEGRA
ybar = 50;
mf_krg0 = mean(xor((Ytest <= ybar), (Ykrg0 <= ybar)))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EGRA-believer
ncycles = 5;
[Xnew, Ynew, stateEGRA] = srgtsMSEGRA(myFN, myFNOPT, ...
    designspace, designspace, srgtOPTKRG, srgtSRGTKRG, ...
    srgtOPTHelpers, srgtSRGTHelpers, ...
    ybar, @srgtsExpectedFeasibility, ncycles, ...
    'ON');

srgtOPTKRGnew = srgtOPTKRG;
srgtOPTKRGnew.P = Xnew;
srgtOPTKRGnew.T = Ynew;
srgtSRGTKRGnew  = srgtsKRGFit(srgtOPTKRGnew);
Ykrgnew         = srgtsKRGEvaluate(Xtest, srgtSRGTKRGnew);
mf_krgnew       = mean(xor((Ytest <= ybar), (Ykrgnew <= ybar)))
