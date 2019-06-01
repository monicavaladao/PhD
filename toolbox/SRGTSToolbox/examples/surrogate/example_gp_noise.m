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
noise     = 2;
nmeasures = 10;
Yall = repmat(feval(myFN, X), 1, nmeasures) + noise*normrnd(0,1,npoints,nmeasures);
Y = mean(Yall,2);

% create test points
npointstest = 101;
Xtest = linspace(designspace(1), designspace(2), npointstest)';
Ytest = feval(myFN, Xtest);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fit surrogate
nugget = mean(std(Yall,0,2)/sqrt(nmeasures));

srgtOPT  = srgtsGPSetOptions(X, Y);
srgtOPT.GP_CovarianceFunction = {'gpml_covSum', {'gpml_covSEard','gpml_covNoise'}};
srgtOPT.GP_LogTheta0 = [-2; 0; log(sqrt(nugget.^2))];

srgtSRGT = srgtsGPFit(srgtOPT);

[Yhat PredVar] = srgtsGPPredictor(Xtest, srgtSRGT);

% alternatively, one can use
% Yhat    = srgtsGPEvaluate(Xtest, srgtSRGT);
% PredVar = srgtsGPPredictionVariance(Xtest, srgtSRGT);

PredVar = PredVar - exp(2*srgtOPT.GP_LogTheta0(3));

CRITERIA = srgtsErrorAnalysis(srgtOPT, srgtSRGT, Ytest, Yhat)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plots
figure(1); clf(1);
plot(X, Y, 'ok', ...
    Xtest, Ytest, '--k', ...
    Xtest, Yhat, '-b', ...
    Xtest, Yhat + sqrt(PredVar), 'r', ...
    Xtest, Yhat - sqrt(PredVar), 'r')
