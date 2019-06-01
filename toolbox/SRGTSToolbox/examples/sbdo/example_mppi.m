%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;
clear all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% basic information about the problem
myFN    = @sasena;  % this could be any user-defined function
myFNOPT = 2;

DesignSpace = [0  0;  % lower bound
    5  5]; % upper bound

NbVariables = size(DesignSpace, 2);

% create DOE
npoints = 12;
X = srgtsScaleVariable(srgtsDOETPLHS(npoints, NbVariables), ...
    [zeros(1, NbVariables); ones(1, NbVariables)], ...
    DesignSpace);
Y = feval(myFN, X, myFNOPT);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fit kriging
srgtOPT  = srgtsKRGSetOptions(X, Y);
srgtSRGT = srgtsKRGFit(srgtOPT);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run EGO
maxNbCycles  = 2;
targetImprov = 0.25;
nbPointsPerCycle = 2;
[x, y, stateMPPIEGO] = srgtsMPPIEGO(myFN, myFNOPT, DesignSpace, DesignSpace, ...
    srgtOPT, srgtSRGT, ...
    targetImprov, nbPointsPerCycle, maxNbCycles, 'ON')
