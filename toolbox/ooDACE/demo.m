%> @file "demo.m"
%> @authors Ivo Couckuyt
%> @version 1.4 ($Revision$)
%> @date $LastChangedDate$
%> @date Copyright 2010-2013
%>
%> This file is part of the ooDACE toolbox
%> and you can redistribute it and/or modify it under the terms of the
%> GNU Affero General Public License version 3 as published by the
%> Free Software Foundation.  With the additional provision that a commercial
%> license must be purchased if the ooDACE toolbox is used, modified, or extended
%> in a commercial setting. For details see the included LICENSE.txt file.
%> When referring to the ooDACE toolbox please make reference to the corresponding
%> publications:
%>   - Blind Kriging: Implementation and performance analysis
%>     I. Couckuyt, A. Forrester, D. Gorissen, F. De Turck, T. Dhaene,
%>     Advances in Engineering Software,
%>     Vol. 49, pp. 1-13, July 2012.
%>   - Surrogate-based infill optimization applied to electromagnetic problems
%>     I. Couckuyt, F. Declercq, T. Dhaene, H. Rogier, L. Knockaert,
%>     International Journal of RF and Microwave Computer-Aided Engineering (RFMiCAE),
%>     Special Issue on Advances in Design Optimization of Microwave/RF Circuits and Systems,
%>     Vol. 20, No. 5, pp. 492-501, September 2010. 
%>
%> Contact : ivo.couckuyt@ugent.be - http://sumo.intec.ugent.be/?q=ooDACE
%> Signature
%>	k = demo(id)
%
% ======================================================================
%> @brief  Provides some examples on how to use the ooDACE toolbox
%>
%> @test Test case 1: Fits an ordinary kriging model on the branin function
%> Covers: ordinary kriging interpolation, marginalLikelihood
%> @test Test case 2: Fits an ordinary kriging model on the bird function
%> Covers: ordinary kriging regression, re-interpolation of variance, pseudoLikelihood, likelihood debug plot
%> @test Test case 3: Fits a blind kriging model on the branin function.
%> Covers: blind kriging
%> @test Test case 4: Fits a cokriging model on a mathematical 1D function.
%> Covers: cokriging
%> @test Test case 5: Fits a stochastic kriging model on the branin function plus some stochastic noise.
%> Covers: stochastic kriging, sigma2 optimization
%>
%> @param id id of the dataset to use (optional)
%> @retval k a ready-to-use kriging model
% ======================================================================
function k = demo(id)

% Check if the toolbox path has been set
if ~exist('mergeStruct.m','file')
    disp('It seems the ooDACE Toolbox path has not yet been setup, running startup now..')
    startup;
end

datasetnames = {'branin_lhd16' 'bird_lhd16' 'branin_lhd16' 'math1d_ck_factorial' 'branin_sk_lhd16'};

if ~exist( 'id', 'var' )
    disp('Test functions:');
    disp(' 1) Branin (ordinary kriging, interpolation)');
    disp(' 2) Bird (ordinary kriging, regression, re-interpolation of variance, pseudoLikelihood, likelihood debug plot)');
    disp(' 3) Branin (blind kriging, interpolation)');
    disp(' 4) 1D illustration (cokriging, interpolation)');
    disp(' 5) Branin + stochastic noise (stochastic kriging, regression)');
    id = input('Choose test function ? ');
end

if id < 1 || id > 5
    error('Invalid demo function.');
end

datasetname = fullfile( 'datasets', datasetnames{id} );

% Load dataset
load(datasetname, 'data');

inDim = data.inDim;
samples = data.samples;
values = data.values;
LB = data.LB;
UB = data.UB;

% create user options struct depending on problem
opts = struct();

if id == 3 % blind kriging
    % explicitly ask for a blind kriging model
    opts.type = 'BlindKriging';
    opts.retuneParameters = true;
    
    % set this if you want to limit the maximal order of the blind kriging model
    % (0=constant, 1=linear,...,4=quartic)
    %opts.regressionMaxOrder = 2; % quadratic and lower terms allowed
elseif id == 2 % regression and re-interpolation
    opts.corrFunc = @corrmatern32;
    
    % likelihood debug plot
    opts.debug = true;
    
    % use pseudoLikelihood (leave-one-out cross validation)
    opts.hpLikelihood = @pseudoLikelihood;
    
    % initial value and bounds of the lambda hyperparameter (regression)
    opts.lambda0 = 1;
    opts.lambdaBounds = [0 ; 5]; % log10 scale
    
    % enabled reinterpolation (predict(x) returns reinterpolated variance instead of the normal one)
    opts.reinterpolation = true;
elseif id == 5 % stochastic kriging
    % Sigma is the intrinsic covariance matirx (=variance of output values)
    opts.Sigma = values(:,2);
    values(:,2) = [];
    
    % for stochastic kriging the process variance sigma2 needs to be included in the MLE
    opts.sigma20 = Inf; % Let ooDACE make a guess for the initial value
    opts.sigma2Bounds = [-1; 5 ]; % log10 scale
    opts.generateHyperparameters0 = true;
    
    % explicitly ask for BasicGaussianProcess (=kriging without scaling), needed for stochastic kriging
    opts.type = 'BasicGaussianProcess';
else
    opts.corrFunc = @corrmatern32;
end

% build model
fprintf('\nBuilding model...');
tic;
k = oodacefit( samples, values, opts );
t = toc;
%fprintf('done (elapsed time %f s)\n\n', t);
fprintf('done\n\n');

% k represents the kriging approximation and can now be used, e.g.,
x = (LB+UB) ./ 2; % middle of domain
[y s2] = k.predict( x );
[dy ds2] = k.predict_derivatives( x );
xval = k.cvpe(); % Cross Validated Prediction Error (using the mean squared error function)
imseval = k.imse();
marginallik = k.marginalLikelihood();
pseudolik = k.pseudoLikelihood();
sigma2 = k.getProcessVariance();
Sigma = k.getSigma(); % intrinsic covariance matrix
if id ~= 4
    [regrFunc expr] = k.regressionFunction(struct('includeCoefficients', false)); % final regression function (internal representation + formatted)
else
    % cokriging doesnt support the symbolic expression
    expr = 'Not available';
end
% ...

fprintf('Evaluating model at (%s).\n', num2str(x, '%g '));
fprintf('Prediction mean = %f. Prediction variance = %f.\n', y, s2);
fprintf('Derivatives of: prediction mean = (%s). prediction variance = (%s).\n', num2str(dy,'%g '), num2str(ds2, '%g '));
fprintf('Leave-one-out crossvalidation: %f (using the mean squared error function).\n', xval);
fprintf('Integrated Mean Square Error: %f.\n', imseval);
fprintf('Marginal likelihood (-log): %f.\n', marginallik);
fprintf('Pseudo likelihood (-log): %f.\n', pseudolik);
fprintf('Process variance: %f\n', sigma2 );
fprintf('Sigma(1,1): %f (first element of intrinsic covariance matrix).\n', full( Sigma(1,1) ) );
fprintf('Formatted regression function: %s\n', expr);
if id == 4 % cokriging
    fprintf('Rho: %f\n', cell2mat( k.getRho() ) );
end
    
h = plotKrigingModel(k, LB, UB);

end % demo
