function [stateEGO npoints ndv popsize helpersID nhelpers] = srgtsSBDOMakeStateMS(srgtOPTKRG, srgtOPTHelpers)

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

[stateEGO npoints ndv popsize] = srgtsSBDOMakeState(srgtOPTKRG);

% ID of the points
% -1: initial sampling
%  0: kriging
%  1 ... nhelpers: helpers
stateEGO.Y_ID = -ones(npoints, 1);
stateEGO.Ypbs_ID = -1;

nhelpers = length(srgtOPTHelpers);
helpersID = cell(1, nhelpers);
for c1 = 1 : nhelpers
    helpersID{c1} = srgtOPTHelpers{c1}.SRGT;
end

stateEGO.NbNewPoints = 0;

return
