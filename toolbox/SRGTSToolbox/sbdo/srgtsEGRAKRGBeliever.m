function [X, Y, stateEGRA] = srgtsEGRAKRGBeliever(actualFN, actualFNOpts, ...
    designSpace, normSpace, srgtOPT, srgtSRGT, ...
	ybar, infillFN, maxNbCycles, npointspercycle, ...
	display)
%Function srgtsEGRAKRGBeliever sequentially adds points to the data set in
%an effort to improve the surrogate accuracy near the limit state. It uses
%the kriging believer heuristic (Ginsbourger et al. 2010) to provide
%multiple points per cycle for the efficient global reliability analysis
%(EGRA) algorithm by Bichon et al. (2008). Thus, for example:
%
%     X = srgtsEGRAKRGBeliever(ACTUALFN, ACTUALFNOPTS,
%     DESIGNSPACE, NORMSPACE,  SRGTOPT, SRGTSRGT,
%     YBAR, INFILLFN, MAXNBCYCLES,  NBPOINTSPERCYCLE, DISPLAY):
%     optimizes the function ACTUALFN that besides the vector of design
%     variables also has the ACTUALFNOPTS input parameters (if no other
%     input is require, insert [] in this field). DESIGNSPACE and NORMSPACE
%     define the physical and normalized spaces. Normalization is not a
%     major requirement (DESIGNSPACE is used by ACTUALFN and NORMSPACE is
%     used in the surrogate fitting). Without normalization, kriging and
%     the actual function operate in the same space). SRGTOPT and SRGTSRGT
%     are the structures that define the surrogate model. In this version
%     of the toolbox, one can use Gaussian process, kriging, or polynomial
%     response surface. YBAR defines the limit state (that is, the
%     sequential sampling will improve accuracy near ACTUALFN = YBAR).
%     INFILLFN is either @srgtsExpectedFeasibility (expected feasibility
%     defined by Bichon et al, 2008) or any other user-defined function.
%     MAXNBCYCLES is the maximum number of sequential sampling cycles.
%     NBPOINTSPERCYCLE is the number of points added in each cycle.
%     Finally, DISPLAY is the level of report shown in the MATLAB/OCTAVE
%     console ('ON' or 'OFF').
%
%     [X, FVAL] = srgtsEGRAKRGBeliever(...): also returns the value of
%     ACTUALFN at X.
%
%     [X, FVAL, STATE] = srgtsEGRAKRGBeliever(...): also returns the state
%     of the sequential sampling procedure with the following information:
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
%For an example, go to .../SRGTSToolbox/examples/sbdo
%
%REFERENCES
%
%Ginsbourger D, Le Riche R, and Carraro L, Kriging is well-suited to
%parallelize optimization, Computational Intelligence in Expensive
%Optimization Problems, Vol. 2, pp. 131162, 2010.
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

[X, Y, stateEGRA] = srgtsRBDODriver(actualFN, actualFNOpts, ...
    designSpace, normSpace, srgtOPT, srgtSRGT, ...
	ybar, infillFN, maxNbCycles, ...
	'srgtsEGRAKRGBeliever', npointspercycle, display);

return
