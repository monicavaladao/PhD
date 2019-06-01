%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;
clear all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% basic information about the problem
myFN = @forrester;  % this could be any user-defined function
designspace = [0;   % lower bound
               1];  % upper bound

ndv = length(designspace(1,:));

% create DOE
npoints = 5;
X = linspace(designspace(1), designspace(2), npoints)';
Y = feval(myFN, X);

% create test points
npointstest = 101;
Xtest = linspace(designspace(1), designspace(2), npointstest)';
Ytest = feval(myFN, Xtest);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fit surrogate
srgtOPT  = srgtsGPSetOptions(X, Y);
srgtOPT.GP_LogTheta0 = [-2; 0];
srgtSRGT = srgtsGPFit(srgtOPT);

[Yhat PredVar] = srgtsGPPredictor(Xtest, srgtSRGT);
% alternatively, one can use
% Yhat    = srgtsGPEvaluate(Xtest, srgtSRGT);
% PredVar = srgtsGPPredictionVariance(Xtest, srgtSRGT);

CRITERIA = srgtsErrorAnalysis(srgtOPT, srgtSRGT, Ytest, Yhat)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plots
figure(1); clf(1);
plot(X, Y, 'ok', ...
    Xtest, Ytest, '--k', ...
    Xtest, Yhat, '-b', ...
    Xtest, Yhat + 2*sqrt(PredVar), 'r', ...
    Xtest, Yhat - 2*sqrt(PredVar), 'r');
