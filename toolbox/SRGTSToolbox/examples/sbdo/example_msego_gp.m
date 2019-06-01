%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc; clear all;

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
% fit surrogates

% Gaussian process
srgtOPT  = srgtsGPSetOptions(X, Y);
srgtSRGT = srgtsGPFit(srgtOPT);

% radial basis function
srgtOPTRBF  = srgtsRBFSetOptions(X, Y);
srgtSRGTRBF = srgtsRBFFit(srgtOPTRBF);

% shepard
srgtOPTSHEP  = srgtsSHEPSetOptions(X, Y);
srgtSRGTSHEP = srgtsSHEPFit(srgtOPTSHEP);

srgtOPTHelpers  = {srgtOPTRBF  srgtOPTSHEP};
srgtSRGTHelpers = {srgtSRGTRBF srgtSRGTSHEP};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run EGO
maxNbCycles  = 2;
[x, y, stateMSEGO] = srgtsMSEGO(myFN, myFNOPT, designspace, designspace, ...
    srgtOPT, srgtSRGT, srgtOPTHelpers, srgtSRGTHelpers, ...
    0.25, @srgtsProbOfImprovement, maxNbCycles, 'ON')
