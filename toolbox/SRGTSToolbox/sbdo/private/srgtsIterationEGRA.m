function Pnew = srgtsIterationEGRA(infillFN, ybar, ...
    srgtOPT, srgtSRGT, normSpace, popsize, NbPoints, NbVariables)

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
% settings
objOPTS.Ytarget  = ybar;
objOPTS.srgtOPT  = srgtOPT;
objOPTS.srgtSRGT = srgtSRGT;
objOPTS.infillFN = infillFN;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run differential evolution (optimizing the infill criterion)
poptm = srgtsSBDOInfillDEOptimization(@srgtsEvalObjEGO, objOPTS, ...
    normSpace, popsize, NbVariables);

if srgtsSBDOCheckDataSet([srgtOPT.P; poptm], NbPoints + 1, NbVariables)
    Pnew = poptm;
else
    Pnew = [];
end

return
