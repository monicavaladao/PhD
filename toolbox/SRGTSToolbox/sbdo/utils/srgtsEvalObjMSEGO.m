function [J C] = srgtsEvalObjMSEGO(x, objOPTS)

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

% Yhat and PredVar
eval(sprintf('Yhat    = srgts%sEvaluate(x, objOPTS.srgtSRGTHelper);', objOPTS.HelperID));

switch objOPTS.srgtOPT.SRGT
    case 'KRG'
        PredVar = srgtsKRGPredictionVariance(x, objOPTS.srgtSRGT);
        
    case 'GP'
        PredVar = srgtsGPPredictionVariance(x, objOPTS.srgtSRGT);

    case 'PRS'
        PredVar = srgtsPRSPredictionVariance(x, objOPTS.srgtOPT.P, objOPTS.srgtSRGT);

end

C = feval(objOPTS.infillFN, objOPTS.Ytarget, Yhat, sqrt(PredVar));
J = -C; % so the "optimizer" can minimize it

return
