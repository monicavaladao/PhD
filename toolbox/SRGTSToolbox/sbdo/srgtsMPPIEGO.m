function [x, y, stateEGO] = srgtsMPPIEGO(actualFN, actualFNOpts, ...
    designSpace, normSpace, srgtOPT, srgtSRGT, ...
	targetImprov, maxNbCycles, npointspercycle, ...
	display)
%Function srgtsMPPIEGO finds the minimum of a function of several variables
%using the efficient global optimization (EGO) and the multiple point
%probability of improvement, as detailed in Viana and Haftka (2010). The
%optimization task runs for a specified number of cycles adding several
%points per cycle. Thus, for example:
%
%     X = srgtsMPPIEGO(ACTUALFN, ACTUALFNOPTS, DESIGNSPACE, NORMSPACE,  ...
%     SRGTOPT, SRGTSRGT, TARGETIMPROV, MAXNBCYCLES, NPOINTSPERCYCLE,
%     DISPLAY):
%     optimizes the function ACTUALFN that besides the vector of design
%     variables also has the ACTUALFNOPTS input parameters (if no other
%     input is require, insert [] in this field). DESIGNSPACE and NORMSPACE
%     define the physical and normalized spaces. Normalization is not a
%     major requirement (DESIGNSPACE is used by ACTUALFN and NORMSPACE is
%     used in the surrogate fitting). Without normalization, kriging and
%     the actual function operate in the same space). SRGTOPT and SRGTSRGT
%     are the structures that define the surrogate model. In this version
%     of the toolbox, one can use Gaussian process, kriging, or polynomial
%     response surface. TARGETIMPROV is the target for the probability of
%     improvement (e.g., TARGETIMPROV = 0.1 for 10% improvement over the
%     present best solution). MAXNBCYCLES is the maximum number of
%     optimization cycles. NPOINTSPERCYCLE is the number of points added
%     in each cycle. Finally, DISPLAY is the level of report shown in the
%     MATLAB/OCTAVE console ('ON' or 'OFF').
%
%     [X, FVAL] = srgtsMPPIEGO(...) returns the value of the objective
%     function FVAL at the solution X.
%
%     [X, FVAL, STATE] = srgtsMPPIEGO(...) returns the state of the
%     optimization procedure with the following information:
%
%     GENERAL PARAMETERS
%          * Iteration    : vector with the number of iterations.
%          * ReasonToStop : string explaining why optimization stopped.
%
%     EGO-SPECIFIC INFORMATION
%          * Ypbs         : present best solution of each iteration.
%          * X            : points added by EGO in the physical space.
%          * Y            : objective value of the points added by EGO.
%
%For an example, go to .../SRGTSToolbox/examples/sbdo
%
%REFERENCES
%
%Viana FAC and Haftka RT, "Surrogate-based optimization with parallel
%simulations using the probability of improvement," 13th AIAA/ISSMO
%Multidisciplinary Analysis and Optimization Conference, Fort Worth, USA,
%September 13-15, 2010. AIAA 2010-9392.

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

[x, y, stateEGO] = srgtsSBDODriver(actualFN, actualFNOpts, ...
    designSpace, normSpace, srgtOPT, srgtSRGT, ...
	targetImprov, @srgtsProbOfImprovement, maxNbCycles, ...
	'srgtsMPPIEGO', npointspercycle, display);


return
