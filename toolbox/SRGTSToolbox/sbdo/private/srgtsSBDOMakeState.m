function [stateEGO npoints ndv popsize] = srgtsSBDOMakeState(srgtOPT)

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

stateEGO.Iteration    = 0;
stateEGO.ReasonToStop = [];

stateEGO.Ypbs = min(srgtOPT.T);

stateEGO.X = [];
stateEGO.Y = [];

[npoints ndv] = size(srgtOPT.P);
if ndv < 10
    popsize = max(20*ndv, 50);
else
    popsize = 100;
end

return
