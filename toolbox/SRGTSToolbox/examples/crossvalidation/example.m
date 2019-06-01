%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% basic information about the problem
myFN    = @sasena;  % this could be any user-defined function
myFNOPT = 2;

DesignSpace = [0  0;  % lower bound
               5  5]; % upper bound

NbVariables = size(DesignSpace, 2);

% create DOE
NbPoints = 12;
X = srgtsScaleVariable(srgtsDOETPLHS(NbPoints, NbVariables), ...
    [zeros(1, NbVariables); ones(1, NbVariables)], ...
    DesignSpace);
Y = feval(myFN, X, myFNOPT);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fit kriging
srgtOPT  = srgtsKRGSetOptions(X, Y);

[PRESSRMS, eXV, yhatXV, predvarXV] = srgtsCrossValidation(srgtOPT)
