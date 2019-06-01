function [x, y, stateEGO] = srgtsSBDODriver(actualFN, actualFNOpts, ...
    designspace, normspace, srgtOPT, srgtSRGT, ...
    targetImprov, infillFN, ncycles, ...
    srgtsSBDOvariant, npointspercycle, display, ...
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
if strcmp(srgtsSBDOvariant, 'srgtsMSEGO')
    srgtOPTHelpers  = varargin{1};
    srgtSRGTHelpers = varargin{2};
    [stateEGO npoints ndv popsize helpersID nhelpers] = srgtsSBDOMakeStateMS(srgtOPT, srgtOPTHelpers);
    npointspercycle = nhelpers + 1;
else
    [stateEGO npoints ndv popsize] = srgtsSBDOMakeState(srgtOPT);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% display
if isequal(display, 'ON')
    Output_String = srgtsSBDODiagnose(actualFN, ndv, srgtsSBDOvariant, npoints, ncycles, npointspercycle);
    fprintf('%s',Output_String);
    disp(sprintf('Iteration\tfval'));
    disp(sprintf('\t%d\t\t%f', 0, stateEGO.Ypbs))
end

timeToStop = 0;
iter       = 1;
while timeToStop == 0
    
    %run one EGO iteration
    switch srgtsSBDOvariant
        case 'srgtsEGO'
            Pnew = srgtsIterationEGO(infillFN, targetImprov, srgtOPT, srgtSRGT, normspace, popsize, npoints, ndv);
        case 'srgtsEGOKRGBeliever'
            Pnew = srgtsIterationEGOKRGBeliever(infillFN, targetImprov, srgtOPT, srgtSRGT, normspace, popsize, npoints, ndv, npointspercycle);
        case 'srgtsMPPIEGO'
            Pnew = srgtsIterationMPPIEGO(infillFN, targetImprov, srgtOPT, srgtSRGT, normspace, popsize, npoints, ndv, npointspercycle);
        case 'srgtsMSEGO'
            [Pnew, npointspercycle, PnewID] = srgtsIterationMSEGO(infillFN, targetImprov, srgtOPT, srgtSRGT, srgtSRGTHelpers, helpersID, nhelpers, normspace, popsize, npoints, ndv);
    end
    
    % sample EGO points
    Xnew = srgtsScaleVariable(Pnew, normspace, designspace);
    if isempty(actualFNOpts)
        Ynew = feval(actualFN, Xnew);
    else
        Ynew = feval(actualFN, Xnew, actualFNOpts);
    end
    
    % update state
    stateEGO.Iteration(iter+1,1) = iter;
    stateEGO.Ypbs(iter+1,1)      = min([stateEGO.Ypbs(iter); Ynew]);
    
    if strcmp(srgtsSBDOvariant, 'srgtsMSEGO')
        stateEGO.Y_ID    = vertcat(stateEGO.Y_ID, PnewID);
        
        if stateEGO.Ypbs(end,1) == stateEGO.Ypbs(end-1,1)
            stateEGO.Ypbs_ID(iter+1,1) = stateEGO.Ypbs_ID(end);
        else
            idxaux = find(Ynew == min(Ynew));
            stateEGO.Ypbs_ID(iter+1,1) = PnewID(idxaux);
        end
        
        stateEGO.NbNewPoints(iter+1,1) = npointspercycle;
        
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
        eval(sprintf('srgtSRGT = srgts%sFit(srgtOPT);', srgtOPT.SRGT));
        
        if strcmp(srgtsSBDOvariant, 'srgtsMSEGO')
            for c1 = 1 : nhelpers
                srgtOPTHelpers{c1}.P = srgtOPT.P;
                srgtOPTHelpers{c1}.T = srgtOPT.T;
                eval(sprintf('srgtSRGTHelpers{c1} = srgts%sFit(srgtOPTHelpers{c1});', srgtOPTHelpers{c1}.SRGT));
            end
        end
        npoints = npoints + npointspercycle;
    end
    
    if isequal(display, 'ON')
        disp(sprintf('\t%d\t\t%f', iter, stateEGO.Ypbs(iter+1,1)));
    end
    iter = iter + 1;
end

stateEGO.ReasonToStop = reason;

X = srgtsScaleVariable([srgtOPT.P; Pnew], normspace, designspace);
Y = [srgtOPT.T; Ynew];

stateEGO.X = X;
stateEGO.Y = Y;

[y idx] = min(Y); y = y(1); idx = idx(1);
x = X(idx, : );

if isequal(display, 'ON')
    strFinal = 'Sequential sampling successfully completed.';
    fprintf('%s\n\n',strFinal);
end

return
