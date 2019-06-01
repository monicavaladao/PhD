function [J C] = srgtsEvalObjEGO(x, objOPTS)

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
switch objOPTS.srgtOPT.SRGT
    case 'KRG'
        [Yhat PredVar] = srgtsKRGPredictor(x, objOPTS.srgtSRGT);

    case 'PRS'
        [Yhat PredVar] = srgtsPRSPredictor(x, objOPTS.srgtOPT.P, objOPTS.srgtSRGT);

    case 'GP'
        [Yhat PredVar] = srgtsGPPredictor(x, objOPTS.srgtSRGT);

end

C = feval(objOPTS.infillFN, objOPTS.Ytarget, Yhat, sqrt(PredVar));
J = -C; % so the "optimizer" can minimize it

return
