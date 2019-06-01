function [Pnew, NbEGOPoints, PnewID] = srgtsIterationMSEGRA(infillFN, ybar, ...
    srgtOPTKRG, srgtSRGTKRG, srgtSRGTHelpers, helpersID, NbHelpers, ...
    normSpace, popsize, NbPoints, NbVariables)

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
objOPTS.srgtOPT  = srgtOPTKRG;
objOPTS.srgtSRGT = srgtSRGTKRG;
objOPTS.infillFN = infillFN;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run differential evolution (optimizing the infill criterion)
paux = srgtsSBDOInfillDEOptimization(@srgtsEvalObjEGO, objOPTS, ...
    normSpace, popsize, NbVariables);

NbEGOPoints = srgtsSBDOCheckDataSet([srgtOPTKRG.P; paux], NbPoints + 1, NbVariables);
if NbEGOPoints
    Pnew   = paux;
    PnewID = 0;
else
    Pnew   = [];
    PnewID = [];
end

objOPTS.srgtOPT  = srgtOPTKRG;
objOPTS.srgtSRGT = srgtSRGTKRG;
for c1 = 1 : NbHelpers
    objOPTS.srgtSRGTHelper = srgtSRGTHelpers{c1};
    objOPTS.HelperID = helpersID{c1};
    
    paux = srgtsSBDOInfillDEOptimization(@srgtsEvalObjMSEGO, objOPTS, ...
        normSpace, popsize, NbVariables);
    
    if srgtsSBDOCheckDataSet([srgtOPTKRG.P; Pnew; paux], NbPoints + NbEGOPoints + 1, NbVariables)
        Pnew        = vertcat(Pnew, paux);
        PnewID      = vertcat(PnewID, c1);
        NbEGOPoints = NbEGOPoints + 1;
    end
end

return
