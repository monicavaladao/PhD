function [stateEGRA npoints ndv popsize] = srgtsRBDOMakeState(srgtOPT, srgtSRGT, ybar)

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

stateEGRA.Iteration    = 0;
stateEGRA.ReasonToStop = [];

stateEGRA.X = [];
stateEGRA.Y = [];

[npoints ndv] = size(srgtOPT.P);
if ndv < 10
    popsize = max(20*ndv, 50);
else
    popsize = 100;
end

stateEGRA.dybar = min(abs(srgtOPT.T - ybar));

switch srgtOPT.SRGT,
    case 'KRG'
        stateEGRA.KRG_DACEModel = srgtSRGT.KRG_DACEModel;
    case 'GP'
        stateEGRA.GP_LogTheta   = srgtSRGT.GP_LogTheta';
end
stateEGRA.KRG_FIT_FnVal = NaN;

return
