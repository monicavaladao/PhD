%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;
clear all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% basic information about the problem
myFN = @forrester;  % this could be any user-defined function
DesignSpace = [0;   % lower bound
               1];  % upper bound

NbVariables = length(DesignSpace(1,:));

% create DOE
NbPoints = 5;
X = linspace(DesignSpace(1), DesignSpace(2), NbPoints)';
Y = feval(myFN, X);

% create test points
NbPointsTest = 101;
Xtest = linspace(DesignSpace(1), DesignSpace(2), NbPointsTest)';
Ytest = feval(myFN, Xtest);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fit surrogates

% kriging
srgtOPTKRG  = srgtsKRGSetOptions(X, Y);
srgtSRGTKRG = srgtsKRGFit(srgtOPTKRG);
[PRESSRMS_KRG, eXV_KRG] = srgtsCrossValidation(srgtOPTKRG);

% polynomial response surface
srgtOPTPRS  = srgtsPRSSetOptions(X, Y);
srgtSRGTPRS = srgtsPRSFit(srgtOPTPRS);
[PRESSRMS_PRS, eXV_PRS] = srgtsCrossValidation(srgtOPTPRS);

% radial basis function
srgtOPTRBF  = srgtsRBFSetOptions(X, Y);
srgtSRGTRBF = srgtsRBFFit(srgtOPTRBF);
[PRESSRMS_RBF, eXV_RBF] = srgtsCrossValidation(srgtOPTRBF);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% computing weights
eXVMatrix = [eXV_KRG eXV_RBF eXV_PRS];
CMatrix   = srgtsWASComputeCMatrix(X, eXVMatrix);

srgtsOPTs   = {srgtOPTKRG  srgtOPTRBF  srgtOPTPRS};
srgtsSRGTs  = {srgtSRGTKRG srgtSRGTRBF srgtSRGTPRS};
WAS_Model   = 'OWSdiag';
WAS_Options = CMatrix;

srgtOPTWAS  = srgtsWASSetOptions(srgtsOPTs, srgtsSRGTs, WAS_Model, WAS_Options);
srgtSRGTWAS = srgtsWASFit(srgtOPTWAS);

[Yhat PredVar] = srgtsWASPredictor(Xtest, srgtSRGTWAS);
% alternatively, one can use
% Yhat    = srgtsWASEvaluate(Xtest, srgtSRGTWAS);
% PredVar = srgtsWASPredictionVariance(Xtest, srgtSRGTWAS);

CRITERIA = srgtsErrorAnalysis(srgtOPTWAS, srgtSRGTWAS, Ytest, Yhat, Xtest)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plots
figure(1); clf(1);
plot(X, Y, 'ok', ...
    Xtest, Ytest, '--k', ...
    Xtest, Yhat, '-b', ...
    Xtest, Yhat + 2*sqrt(PredVar), 'r', ...
    Xtest, Yhat - 2*sqrt(PredVar), 'r');
