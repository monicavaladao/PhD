function [poptm foptm] = srgtsSBDOInfillDEOptimization(infillDEObj, objOPTS, ...
    normSpace, popsize, NbVariables)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Felipe A. C. Viana
% felipeacviana@gmail.com
% http://sites.google.com/site/felipeacviana
%
% This program is free software; you can redistribute it and/or
% modify it. This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run differential evolution (optimizing the infill criterion)

% itermax = 5; % maximum of function evaluations = itermax*popsize
% foptm = Inf;
% for c1 = 1 : 1
itermax = 100; % maximum of function evaluations = itermax*popsize
foptm = Inf;
for c1 = 1 : 4
    [ptemp ftemp] = srgtsOPTMDE(infillDEObj, -Inf, NbVariables, ...
        normSpace(1,:), normSpace(2,:), objOPTS, popsize, itermax, ...
        0.8, 0.8, 7, 0); % DE parameters
    if ftemp < foptm
        poptm = ptemp;
    end
end

return
