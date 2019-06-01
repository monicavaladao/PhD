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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run EGO
maxNbCycles  = 2;
[x, y, stateEGO] = srgtsEGO(myFN, myFNOPT, designspace, designspace, ...
     srgtOPT, srgtSRGT, [], @srgtsExpectedImprovement, maxNbCycles, 'ON')
 
% [x, y, stateEGO] = srgtsEGO(myFN, myFNOPT, designspace, designspace, ...
%      srgtOPT, srgtSRGT, 0.25, @srgtsProbOfImprovement, maxNbCycles, 'ON')
