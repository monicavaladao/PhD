function [X, Y,stateEGRA] = srgtsMSEGRA(actualFN, actualFNOpts, ...
    designSpace, normSpace, srgtOPT, srgtSRGT, ...
	srgtOPTHelpers, srgtSRGTHelpers, ...
    ybar, infillFN, maxNbCycles, ...
	display)
%Function srgtsMSEGRA sequentially adds points to the data set in
%an effort to improve the surrogate accuracy near the limit state. It uses
%the multiple surrogate efficient global optimization (MSEGO)
%algorithm by Viana et al. (2010) to provide multiple points per cycle for
%the efficient global reliability analysis (EGRA) algorithm by Bichon
%et al. (2008). Thus, for example:
%
%     X = srgtsMSEGRA(ACTUALFN, ACTUALFNOPTS, DESIGNSPACE, NORMSPACE, ...
%     SRGTOPTKRG, SRGTSRGTKRG, SRGTOPTHELPERS, SRGTSRGTHELPERS, ...
%     YBAR, INFILLFN, MAXNBCYCLES, DISPLAY):
%     optimizes the function ACTUALFN that besides the vector of design
%     variables also has the ACTUALFNOPTS input parameters (if no other
%     input is require, insert [] in this field). DESIGNSPACE and NORMSPACE
%     define the physical and normalized spaces. Normalization is not a
%     major requirement (DESIGNSPACE is used by ACTUALFN and NORMSPACE is
%     used in the surrogate fitting). Without normalization, kriging and
%     the actual function operate in the same space). SRGTOPT and SRGTSRGT
%     are the structures that define the kriging model. SRGTOPTHELPERS and
%     SRGTSRGTHELPERS are structures that define the set of surrogates that
%     will assit the kriging model. YBAR defines the limit state (that is, the
%     sequential sampling will improve accuracy near ACTUALFN = YBAR).
%     INFILLFN is either @srgtsExpectedFeasibility (expected feasibility
%     defined by Bichon et al, 2008) or any other user-defined function.
%     MAXNBCYCLES is the maximum number of optimization cycles. Finally,
%     DISPLAY is the level of report shown in the MATLAB/OCTAVE console
%     ('ON' or 'OFF').
%
%     [X, FVAL] = srgtsMSEGRA(...) returns the value of the objective
%     function FVAL at the solution X.
%
%     [X, FVAL, STATE] = srgtsMSEGRA(...) returns the state of the
%     optimization procedure with the following information:
%
%     GENERAL PARAMETERS
%          * Iteration    : vector with the number of iterations.
%          * ReasonToStop : string explaining why sequential sampling
%                           stopped.
%
%     EGRA-SPECIFIC INFORMATION
%          * X     : points added by EGO in the physical space.
%          * Y     : function values of the points added by EGRA.
%          * dybar : difference between function value and limit state.
%
%     SURROGATE-SPECIFIC INFORMATION
%          * MODEL      : vector of SURROGATE structure.
%          * FIT_FN_VAL : value of the loss function used to fit the
%                         surrogate.
%
%     MSEGO-SPECIFIC INFORMATION
%          * Y_ID         : ID (i.e. surrogate that suggested) of the
%                           points (-1: initial sampling, 0:
%                           kriging, 1 ... NbHelpers: helpers).
%          * Ypbs_ID      : ID of the present best solution.
%          * NbNewPoints  : number of new points per cycle.
%          * Helper_Model : cell with vectors of SURROGATE structure for
%                           each supporting surrogate.
%
%For an example, go to .../SRGTSToolbox/examples/sbdo
%
%REFERENCES
%
%Viana FAC, Haftka RT, and Watson LT, "Why not run the efficient global
%optimization algorithm with multiple surrogates?," 51th
%AIAA/ASME/ASCE/AHS/ASC Structures, Structural Dynamics, and Materials
%Conference, Orlando, USA, April 12 - 15, 2010. AIAA 2010-3090.
%
%Bichon BJ, Eldred MS, Swiler LP, Mahadevan S, and McFarland J, Efficient
%global reliability analysis for nonlinear implicit performance functions,
%AIAA Journal, Vol. 46 (10), pp. 2459–2468, 2008.

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
if ~iscell(srgtOPTHelpers)
    srgtOPTHelpers  = {srgtOPTHelpers};
    srgtSRGTHelpers = {srgtSRGTHelpers};
end

[X, Y, stateEGRA] = srgtsRBDODriver(actualFN, actualFNOpts, ...
    designSpace, normSpace, srgtOPT, srgtSRGT, ...
	ybar, infillFN, maxNbCycles, ...
	'srgtsMSEGRA', [], display, ...
    srgtOPTHelpers, srgtSRGTHelpers);

return
