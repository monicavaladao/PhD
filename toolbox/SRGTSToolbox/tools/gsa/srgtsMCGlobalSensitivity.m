function output = srgtsMCGlobalSensitivity(srgtSRGT, SRGT, Xa, Xb)
%Function srgtsMCGlobalSensitivity calculates individual effects and total
%effects (Sobol, 2001) using Monte Carlo simulations. Thus, for example:
%
%     OUTPUT = srgtsMCGlobalSensitivity(srgtSRGT, SRGT, SPACE, nMCpoints):
%     performs the global sensitivity analysis using Monte Carlo
%     simulations. srgtSRGT is the surrogate structure, SRGT is the string
%     that identifies the surrogate, SPACE is the matrix defining the
%     input space used to fit the surrogate (first and second rows are the
%     lower and upper bounds, respectively) and nMCpoints is the number of
%     Monte Carlo samples (nMCpoints > 5000). OUTPUT is a structure with
%     the following fields:
%
%          * individual : vector of individual sensitivity indices
%                         (NDV x 1  vector).
%          * total      : vector of total sensitivity indices
%                         (NDV x 1  vector).
%
%     OUTPUT = srgtsMCGlobalSensitivity(srgtSRGT, SRGT, XA, XB):
%     performs the global sensitivity analysis using Monte Carlo
%     simulations. srgtSRGT is the surrogate structure, SRGT is the string
%     that identifies the surrogate, XA and XB are the two samples (input
%     space) used in the Monte Carlo integration.
%
%Example:
%     % basic information about the optimization problem
%     DesignSpace = [0  0;   % lower bound
%                    1  1];  % upper bound
%
%     % create a DoE
%     ndv       = 2;
%     ntraining = 12;
%     X = lhsdesign(ntraining, ndv);
%
%     % evaluate analysis function at X points
%     Y = myAnalysis(X); % this is a user-defined function
%
%     % fit srgtSRGT models
%     srgtOPT  = srgtsKRGSetOptions(X, Y);
%     srgtSRGT = srgtsKRGFit(srgtOPT);
%
%     % global sensitivity analysis
%     nMCpoints = 50e3; % number of points for Monte Carlo simulation
%     output    = srgtsMCGlobalSensitivity(srgtSRGT, nMCpoints);
%
%REFERENCES
%
% Sobol IM, Global sensitivity indices for nonlinear mathematical models 
% and their Monte Carlo estimates,Mathematics and Computers in Simulation,
% Vol. 55 (1-3), pp. 271-280, 2001.

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

% the third and fourth input arguments are called Xa and Xb just to save
% time associated with deleting these huge matrices (in case they are
% actually the Monte Carlo points)

if isscalar(Xb) % srgtSRGT, SRGT, normspace, nMCpoints
    normspace = Xa;
    nMCpoints = Xb;
    ndv       = length(normspace(1,:));
    
    % generate A matrix
    Xa = rand(nMCpoints, ndv);
    Xa = srgtsScaleVariable(Xa, [zeros(1,ndv); ones(1,ndv)], normspace);
    
    % generate B matrix
    Xb = rand(nMCpoints, ndv);
    Xb = srgtsScaleVariable(Xb, [zeros(1,ndv); ones(1,ndv)], normspace);
    
else % srgtSRGT, SRGT, Xa, Xb
    nMCpoints = length(Xa(:,1));
    ndv       = length(Xa(1,:));
end

% generate C matrices for each input variable by replacing the ith column
% of B with the ith column of A
C = zeros(nMCpoints,ndv,ndv);
for c1 = 1 : ndv
    C(:,:,c1)  = Xb;
    C(:,c1,c1) = Xa(:,c1);
end

% compute the output vectors
ya = zeros(nMCpoints,1);
yb = zeros(nMCpoints,1);
yc = zeros(nMCpoints,1,ndv);
for c1 = 1 : nMCpoints
    eval(sprintf('ya(c1,1) = srgts%sEvaluate(Xa(c1,:), srgtSRGT);', SRGT));
    eval(sprintf('yb(c1,1) = srgts%sEvaluate(Xb(c1,:), srgtSRGT);', SRGT));
    for c2 = 1 : ndv
        eval(sprintf('yc(c1,1,c2) = srgts%sEvaluate(C(c1,:,c2), srgtSRGT);', SRGT));
    end
end

% compute mean values
fmean2 = (sum(ya(:,1))/nMCpoints)^2;

% calculate individual sensitivity indices
Sindividual = zeros(ndv,1);
for c1 = 1 : ndv
    % first order sensitivity (individual effect)
    Sindividual(c1) = (dot(ya(:,1),yc(:,1,c1))/nMCpoints - fmean2)/...
        (dot(ya(:,1),ya(:,1))/nMCpoints - fmean2);
end

% calculate total effect indices
Stotal = zeros(ndv,1);
for c1 = 1 : ndv
    % first order sensitivity (total effect)
    Stotal(c1) = 1 - ((dot(yb(:,1),yc(:,1,c1))/nMCpoints - fmean2)...
        /(dot(ya(:,1),ya(:,1))/nMCpoints - fmean2));
end

output.individual = Sindividual;
output.total      = Stotal;

return
