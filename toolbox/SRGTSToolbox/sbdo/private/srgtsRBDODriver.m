function [X, Y, stateEGRA] = srgtsRBDODriver(actualFN, actualFNOpts, ...
    designspace, normspace, srgtOPT, srgtSRGT, ...
    ybar, infillFN, ncycles, ...
    srgtsRBDOvariant, npointspercycle, display, ...
    varargin)

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

display = upper(display);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EGO parameters
if strcmp(srgtsRBDOvariant, 'srgtsMSEGRA')
    srgtOPTHelpers  = varargin{1};
    srgtSRGTHelpers = varargin{2};
    [stateEGRA npoints ndv popsize helpersID nhelpers] = srgtsRBDOMakeStateMS(srgtOPT, srgtSRGT, srgtOPTHelpers, srgtSRGTHelpers, ybar);
    npointspercycle = nhelpers + 1;
else
    [stateEGRA npoints ndv popsize] = srgtsRBDOMakeState(srgtOPT, srgtSRGT, ybar);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% display
if isequal(display, 'ON')
    Output_String = srgtsSBDODiagnose(actualFN, ndv, srgtsRBDOvariant, npoints, ncycles, npointspercycle);
    fprintf('%s',Output_String);
    disp(sprintf('Iteration\td(Ynew, ybar = %f)', ybar));
    disp(sprintf('\t%d\t\t%f', 0, stateEGRA.dybar))
end

timeToStop = 0;
iter       = 1;
while timeToStop == 0
    
    %run one EGO iteration
    switch srgtsRBDOvariant
        case 'srgtsEGRA'
            Pnew = srgtsIterationEGRA(infillFN, ybar, srgtOPT, srgtSRGT, normspace, popsize, npoints, ndv);
        case 'srgtsEGRAKRGBeliever'
            Pnew = srgtsIterationEGRAKRGBeliever(infillFN, ybar, srgtOPT, srgtSRGT, normspace, popsize, npoints, ndv, npointspercycle);
        case 'srgtsMSEGRA'
            [Pnew, npointspercycle, PnewID] = srgtsIterationMSEGRA(infillFN, ybar, srgtOPT, srgtSRGT, srgtSRGTHelpers, helpersID, nhelpers, normspace, popsize, npoints, ndv);
    end
    
    % sample EGO points
    Xnew = srgtsScaleVariable(Pnew, normspace, designspace);
    if isempty(actualFNOpts)
        Ynew = feval(actualFN, Xnew);
    else
        Ynew = feval(actualFN, Xnew, actualFNOpts);
    end
    
    % update state
    stateEGRA.Iteration(iter+1,1) = iter;
    stateEGRA.dybar(iter+1,1) = min(abs(Ynew - ybar));
    
    if strcmp(srgtsRBDOvariant, 'srgtsMSEGRA')
        stateEGRA.Y_ID    = vertcat(stateEGRA.Y_ID, PnewID);
        stateEGRA.NbNewPoints(iter+1,1) = npointspercycle;
    end
    
    % check whether it is time to stop or not
    if ~strcmp(srgtOPT.SRGT, 'KRG')
        srgtSRGT.KRG_DACEModel = [];
    end
    [timeToStop reason] = srgtsSBDOIsItTimeToStop(srgtSRGT.KRG_DACEModel, iter, ncycles);
    
    if ~timeToStop
        % update surrogates
        srgtOPT.P = [srgtOPT.P; Pnew];
        srgtOPT.T = [srgtOPT.T; Ynew];
        eval(sprintf('[srgtSRGT srgtsSTT] = srgts%sFit(srgtOPT);', srgtOPT.SRGT));
        switch srgtOPT.SRGT
            case 'KRG'
                stateEGRA.KRG_DACEModel(iter+1,:) = srgtSRGT.KRG_DACEModel;
            case 'GP'
                stateEGRA.GP_LogTheta(iter+1,:)  = srgtSRGT.GP_LogTheta';
        end
        stateEGRA.KRG_FIT_FnVal(iter+1,:) = srgtsSTT.FIT_FnVal;
        
        if strcmp(srgtsRBDOvariant, 'srgtsMSEGRA')
            for c1 = 1 : nhelpers
                srgtOPTHelpers{c1}.P = srgtOPT.P;
                srgtOPTHelpers{c1}.T = srgtOPT.T;
                eval(sprintf('srgtSRGTHelpers{c1} = srgts%sFit(srgtOPTHelpers{c1});', srgtOPTHelpers{c1}.SRGT));
                switch srgtOPTHelpers{c1}.SRGT
                    case 'RBF'
                        stateEGRA.Helper_Model{iter+1,c1}.RBF_Model  = srgtSRGTHelpers{c1}.RBF_Model;
                    case 'SHEP'
                        stateEGRA.Helper_Model{iter+1,c1}.SHEP_Beta  = srgtSRGTHelpers{c1}.SHEP_Beta;
                        stateEGRA.Helper_Model{iter+1,c1}.SHEP_Radii = srgtSRGTHelpers{c1}.SHEP_Radii;
                    case 'SVR'
                        stateEGRA.Helper_Model{iter+1,c1}.SVR_Kernel        = srgtSRGTHelpers{c1}.SVR_Kernel;
                        stateEGRA.Helper_Model{iter+1,c1}.SVR_KernelOptions = srgtSRGTHelpers{c1}.SVR_KernelOptions;
                        stateEGRA.Helper_Model{iter+1,c1}.SVR_NbSV          = srgtSRGTHelpers{c1}.SVR_NbSV;
                        stateEGRA.Helper_Model{iter+1,c1}.SVR_DiffLagMult   = srgtSRGTHelpers{c1}.SVR_DiffLagMult;
                        stateEGRA.Helper_Model{iter+1,c1}.SVR_Bias          = srgtSRGTHelpers{c1}.SVR_Bias;
                end
            end
        end
        npoints = npoints + npointspercycle;
    end
    
    if isequal(display, 'ON')
        disp(sprintf('\t%d\t\t%f', iter, stateEGRA.dybar(iter+1,1)));
    end
    iter = iter + 1;
end

stateEGRA.ReasonToStop = reason;

X = srgtsScaleVariable([srgtOPT.P; Pnew], normspace, designspace);
Y = [srgtOPT.T; Ynew];

stateEGRA.X = X;
stateEGRA.Y = Y;

if isequal(display, 'ON')
    strFinal = 'Sequential sampling successfully completed.';
    fprintf('%s\n\n',strFinal);
end

return
