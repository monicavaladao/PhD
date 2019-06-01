function Pnew = srgtsIterationEGRAKRGBeliever(infillFN, ybar, ...
    srgtOPT, srgtSRGT, normSpace, popsize, NbPoints, NbVariables, nbPointsPerCycle)

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

srgtOPT.FIT_Fn = @dace_fit;
srgtOPT.KRG_LowerBound = [];
srgtOPT.KRG_UpperBound = [];

Pnew = zeros(nbPointsPerCycle, NbVariables);
objOPTS.Ytarget  = ybar;
for c1 = 1 : nbPointsPerCycle
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % settings
    objOPTS.srgtOPT  = srgtOPT;
    objOPTS.srgtSRGT = srgtSRGT;
    objOPTS.infillFN = infillFN;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % run differential evolution (optimizing the infill criterion)
    Paux = srgtsSBDOInfillDEOptimization(@srgtsEvalObjEGO, objOPTS, ...
        normSpace, popsize, NbVariables);
    
    if ~srgtsSBDOCheckDataSet([srgtOPT.P; Paux], NbPoints + 1, NbVariables)
        Paux = srgtsDOELHSFilling(srgtsScaleVariable(srgtOPT.P, ...
                                                     normSpace, ...
                                                     [zeros(1, NbVariables);
                                                      ones(1, NbVariables)]), 1, ...
                                                      'criterion', 'maximin', 'iterations',50);

        Paux = srgtsScaleVariable(Paux(end,:), [zeros(1, NbVariables); ones(1, NbVariables)], normSpace);
        Pnew(c1,:) = Paux;
    end
    Pnew(c1,:)  = Paux;
    
    if c1 < nbPointsPerCycle
        srgtOPT.P = [srgtOPT.P; Paux];
        eval(sprintf('Yaux = srgts%sEvaluate(Paux, srgtSRGT);', srgtOPT.SRGT));
        srgtOPT.T = [srgtOPT.T; Yaux];
        eval(sprintf('srgtSRGT  = srgts%sFit(srgtOPT);', srgtOPT.SRGT));
    end
    NbPoints = NbPoints + 1;
    
end

return
