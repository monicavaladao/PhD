function [stateEGRA npoints ndv popsize helpersID nhelpers] = srgtsRBDOMakeStateMS(srgtOPTKRG, srgtSRGTKRG, srgtOPTHelpers, srgtSRGTHelpers, ybar)

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

[stateEGRA npoints ndv popsize] = srgtsRBDOMakeState(srgtOPTKRG, srgtSRGTKRG, ybar);

% ID of the points
% -1: initial sampling
%  0: kriging
%  1 ... nhelpers: helpers
stateEGRA.Y_ID = -ones(npoints, 1);

nhelpers = length(srgtOPTHelpers);
helpersID = cell(1, nhelpers);
for c1 = 1 : nhelpers
    helpersID{c1} = srgtOPTHelpers{c1}.SRGT;
end

stateEGRA.NbNewPoints = 0;

for c1 = 1 : nhelpers
    switch srgtOPTHelpers{c1}.SRGT
        case 'RBF'
            stateEGRA.Helper_Model{1,c1}.RBF_Model  = srgtSRGTHelpers{c1}.RBF_Model;
        case 'SHEP'
            stateEGRA.Helper_Model{1,c1}.SHEP_Beta  = srgtSRGTHelpers{c1}.SHEP_Beta;
            stateEGRA.Helper_Model{1,c1}.SHEP_Radii = srgtSRGTHelpers{c1}.SHEP_Radii;
        case 'SVR'
            stateEGRA.Helper_Model{1,c1}.SVR_Kernel        = srgtSRGTHelpers{c1}.SVR_Kernel;
            stateEGRA.Helper_Model{1,c1}.SVR_KernelOptions = srgtSRGTHelpers{c1}.SVR_KernelOptions;
            stateEGRA.Helper_Model{1,c1}.SVR_NbSV          = srgtSRGTHelpers{c1}.SVR_NbSV;
            stateEGRA.Helper_Model{1,c1}.SVR_DiffLagMult   = srgtSRGTHelpers{c1}.SVR_DiffLagMult;
            stateEGRA.Helper_Model{1,c1}.SVR_Bias          = srgtSRGTHelpers{c1}.SVR_Bias;
    end
end

return
