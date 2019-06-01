function [J C] = srgtsEvalObjMPPIEGO(x, objOPTS)

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
[J C] = srgtsEvalObjEGO(x, objOPTS);

if objOPTS.idxPoint > 1
    dnew = zeros(objOPTS.idxPoint - 1,1);
    for c2 = 1 : objOPTS.idxPoint - 1
        dnew(c2) = pdist([x; objOPTS.Pnew(c2,:)], 'euclidean');
    end
    dnew = min(dnew);
    mask = dnew > 0.01*sqrt(objOPTS.NbVariables);
else
    mask = 1;
end

J = -C*mask; % so the "optimizer" can minimize it

return
