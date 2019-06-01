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
% global sensitivity analysis
nMCpoints = 10e3;
output = srgtsMCGlobalSensitivity(srgtSRGT, srgtOPT.SRGT, designspace, nMCpoints)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plots
bar([output.individual output.total]);
xlabel('design variable');
ylabel('sensitivity index');
legend('individual', 'total');
set(gca, 'XTick', [1 2], 'XTickLabel', {'x_1', 'x_2'});