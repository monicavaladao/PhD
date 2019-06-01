function [x, y, stateEGO] = srgtsMSEGO(actualFN, actualFNOpts, ...
    designspace, normspace, srgtOPT, srgtSRGT, ...
	srgtOPTHelpers, srgtSRGTHelpers, ...
    targetImprov, infillFN, ncycles, ...
	display)
%Function srgtsMSEGO finds the minimum of a function of several variables
%using the multiple surrogate efficient global optimization (MSEGO)
%algorithm by Viana et al. (2010). The optimization task runs for a
%specified number of cycles adding several points per cycle. Thus, for
%example:
%
%     X = srgtsMSEGO(ACTUALFN, ACTUALFNOPTS, DESIGNSPACE, NORMSPACE, ...
%     SRGTOPTKRG, SRGTSRGTKRG, SRGTOPTHELPERS, SRGTSRGTHELPERS, ...
%     TARGETIMPROV, INFILLFN, MAXNBCYCLES, DISPLAY):
%     optimizes the function ACTUALFN that besides the vector of design
%     variables also has the ACTUALFNOPTS input parameters (if no other
%     input is require, insert [] in this field). DESIGNSPACE and NORMSPACE
%     define the physical and normalized spaces. Normalization is not a
%     major requirement (DESIGNSPACE is used by ACTUALFN and NORMSPACE is
%     used in the surrogate fitting). Without normalization, kriging and
%     the actual function operate in the same space). SRGTOPT and SRGTSRGT
%     are the structures that define the kriging model. SRGTOPTHELPERS and
%     SRGTSRGTHELPERS are structures that define the set of surrogates that
%     will assit the kriging model. TARGETIMPROV is the
%     target for the probability of improvement (e.g., TARGETIMPROV = 0.1
%     for 10% improvement over the present best solution). TARGETIMPROV is
%     [] is the expected improvement is used. INFILLFN is either
%     @srgtsProbOfImprovement (probability of improvement) or
%     @srgtsExpectedImprovement (expected improvement). MAXNBCYCLES is the
%     maximum number of optimization cycles. Finally, DISPLAY is the level
%     of report shown in the MATLAB/OCTAVE console ('ON' or 'OFF').
%
%     [X, FVAL] = srgtsMSEGO(...) returns the value of the objective
%     function FVAL at the solution X.
%
%     [X, FVAL, STATE] = srgtsMSEGO(...) returns the state of the
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
%     MSEGO-SPECIFIC INFORMATION
%          * Y_ID         : ID (i.e. surrogate that suggested) of the
%                           points (-1: initial sampling, 0:
%                           kriging, 1 ... NbHelpers: helpers).
%          * Ypbs_ID      : ID of the present best solution.
%          * NbNewPoints  : number of new points per cycle.
%
%For an example, go to .../SRGTSToolbox/examples/sbdo
%
%REFERENCES
%
%Viana FAC, Haftka RT, and Watson LT, "Why not run the efficient global
%optimization algorithm with multiple surrogates?," 51th
%AIAA/ASME/ASCE/AHS/ASC Structures, Structural Dynamics, and Materials
%Conference, Orlando, USA, April 12 - 15, 2010. AIAA 2010-3090.

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
    designspace, normspace, srgtOPT, srgtSRGT, ...
	targetImprov, infillFN, ncycles, ...
	'srgtsMSEGO', [], display, ...
    srgtOPTHelpers, srgtSRGTHelpers);

return
