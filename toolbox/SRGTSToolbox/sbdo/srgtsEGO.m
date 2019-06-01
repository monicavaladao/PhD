function [x, y, stateEGO] = srgtsEGO(actualFN, actualFNOpts, ...
    designSpace, normSpace, srgtOPT, srgtSRGT, ...
	targetImprov, infillFN, maxNbCycles, ...
	display)
%Function srgtsEGO finds the minimum of a function of several variables
%using the efficient global optimization (EGO) algorithm by Jones et al.
%(1998). The optimization task runs for a specified number of cycles adding
%one point at a time. Thus, for example:
%
%     X = srgtsEGO(ACTUALFN, ACTUALFNOPTS, DESIGNSPACE, NORMSPACE, ...
%     SRGTOPT, SRGTSRGT, TARGETIMPROV, INFILLFN, MAXNBCYCLES, DISPLAY):
%     optimizes the function ACTUALFN that besides the vector of design
%     variables can also take ACTUALFNOPTS input parameters (if no other
%     input is require, insert [] in this field). DESIGNSPACE and NORMSPACE
%     define the physical and normalized spaces. Normalization is not a
%     major requirement (DESIGNSPACE is used by ACTUALFN and NORMSPACE is
%     used in the surrogate fitting). Without normalization, kriging and
%     the actual function operate in the same space). SRGTOPT and SRGTSRGT
%     are the structures that define the surrogate model. In this version
%     of the toolbox, one can use Gaussian process, kriging, or polynomial
%     response surface. TARGETIMPROV is the target for the probability of
%     improvement (e.g., TARGETIMPROV = 0.1 for 10% improvement over the
%     present best solution). TARGETIMPROV is [] is the expected
%     improvement is used. INFILLFN is either @srgtsProbOfImprovement
%     (probability of improvement) or @srgtsExpectedImprovement (expected
%     improvement). MAXNBCYCLES is the maximum number of optimization
%     cycles. Finally, DISPLAY is the level of report shown in the
%     MATLAB/OCTAVE console ('ON' or 'OFF').
%
%     [X, FVAL] = srgtsEGO(...): returns the value of the objective
%     function FVAL at the solution X.
%
%     [X, FVAL, STATE] = srgtsEGO(...): returns the state of the
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
%Jones D, Schonlau M, and Welch W, Efficient global optimization of
%expensive black-box functions, Journal of Global Optimization, Vol. 13,
%No. 4, pp. 455-492, 1998.

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
	targetImprov, infillFN, maxNbCycles, ...
	'srgtsEGO', 1, display);

return
