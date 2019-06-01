%> @file "@BlindKriging/fit.m"
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
%>	[this IK] = fit( this, samples, values )
%
% ======================================================================
%> Need to be invoked before calling any of the prediction methods.
% ======================================================================
function [this IK] = fit( this, samples, values )

%% useful constants
[n p] = size(samples); % 'number of samples' 'dimension'

%% Normalize samples and values
% NOTE: the scaling is also done in the subclass Kriging
% The scaling here is only so that the orthogonal polynomial encoding is correct and should not be
% further used!!! (dirthy hack)
inputAvg = mean(samples);
inputStd = std(samples);
tmp_samples = (samples - repmat(inputAvg,n,1)) ./ repmat(inputStd,n,1);

%% Regression matrix preprocessing
% process candidate features options
if length( this.options.regressionMaxOrder ) == 1
	this.options.regressionMaxOrder = this.options.regressionMaxOrder(ones(1,p));
elseif length( this.options.regressionMaxOrder ) ~= p
	error('size of regressionMaxOrder should be 1 or equal to the number of dimensions (%i)', p);
end

%% Generate orthogonal polynomial encoding (features)
order = max(this.options.regressionMaxOrder);
lj = cell(p,1); % levels lj for dimensions j=1..p
dj = cell(p,1); % degrees dj for dimensions j=1..p
candidateFeatures = zeros( n, order*p ); % - candidate features from sample matrix
this.polyScaling = zeros( p, order ); % - scaling constants
for j=1:p % 1:dimension 
    % dj: individual degree matrics
   	dj{j} = zeros( this.options.regressionMaxOrder(j), p*order );

	idx1 = 1:this.options.regressionMaxOrder(j);
	idx2 = j:p:(p*this.options.regressionMaxOrder(j));
	dj{j}( sub2ind( size(dj{j}), idx1, idx2 ) ) = 1;

    % lj: individual levels
    k = this.options.regressionMaxOrder(j) + 1; % number of levels for this factor

    p1 = min( tmp_samples(:,j), [], 1 );
    p2 = max( tmp_samples(:,j), [], 1 );

    levels = zeros( k, 1 );
    idx1 = (1:k)';
    idx2 = linspace( 0, 1, k )';
    levels( idx1, : ) = p1 + idx2 .* (p2-p1);

    lj{j} = levels;

    % polynomial coding
    m = mean(levels);
    delta = levels(2,:) - levels(1,:);

    %
    Uj = this.polynomialCoding( levels, m, k, delta );
    this.polyScaling(j, :) = sqrt(sum(Uj.^2, 1));

    % polynomial coding
	m = mean(levels);
	delta = levels(2,:) - levels(1,:);
	
	%
	Uj = this.polynomialCoding( levels, m, k, delta );
	this.polyScaling(j, :) = sqrt(sum(Uj.^2, 1));
	
	candidateFeatures(:,[j:p:end]) = sqrt(k) .* this.polynomialCoding( tmp_samples(:,j), m, k, delta ) ./ repmat(this.polyScaling(j, :), n, 1 );
end
this.levels = lj;

% create full degrees matrix from individual dj's
[degrees usedIdx] = this.generateDegrees( dj );

% Construct full model matrix U
U = buildVandermondeMatrix( candidateFeatures, degrees, cfix( @powerBase, size(candidateFeatures,2) ) );

% parse initial regression function
if ischar( this.regressionFcn )
	% easy to use + compatible with DACE toolbox
	switch this.regressionFcn
        case ''
            this.idxTerms = []; % no regression function (constant=0)
		case 'regpoly1'
            idx = sum( degrees(:,p+1:end), 2 ); % find >linear terms
			this.idxTerms = find(~idx).'; % only linear terms
		case 'regpoly2'
            idx = sum( degrees(:,2*p+1:end), 2 ); % find >quadratic terms
			this.idxTerms = find(~idx).'; % + quadratic interactions
        case 'regpoly3'
            idx = sum( degrees(:,3*p+1:end), 2 ); % find >cubic terms
			this.idxTerms = find(~idx).'; % + cubic interactions
		case 'regpoly4'
            % NOTE: as quartic is the higest reported,
            % we dont have to do this and can just take the complete degrees matrix
            idx = sum( degrees(:,4*p+1:end), 2 ); % find >quartic terms
			this.idxTerms = find(~idx).'; % + quartic interactions
		otherwise % 'regpoly0'
			this.idxTerms = 1; % only intercept
    end
    this.regressionFcn = degrees(this.idxTerms,:);
else	
    % map custom matrix to candidate features
	idx = ismember( degrees, this.regressionFcn, 'rows' );
	this.idxTerms = find( idx ~= 0 ).';
end

% if hp already given then model is just updated with new samples (e.g., for xval)
if ~isempty( this.hyperparameters )
    this = this.fit@Kriging(samples, values);
    return;
end

%% Fit initial kriging model
this = this.fit@Kriging(samples, values);
% IMPORTANT: this.samples and this.values are properly scaled now. use them from now on

F = this.getRegressionMatrix(); % retrieve current model matrix
% -> this is the 'optimization variable'

%% Feature selection search strategy

% setup metric function handle
% handles multiple outputs = take avg score
if size( values, 2 ) > 1
    this.options.regressionMetric = @(a) mean( feval(this.options.regressionMetric, a) );
end
% handle complex output = take magnitude
if ~any( isreal( this.getValues() ) )
    this.options.regressionMetric = @(a) abs( feval(this.options.regressionMetric, a) );
end

% initial leave-one out score for blind kriging process
scores = feval( this.options.regressionMetric, this );

%% Variable selection
% Setup new struct for blind kriging improvements

IK = this; % store IK model for reference purposes

% transform samples for the factor selection procedure (the 'blind' part)
% Orthogonal polynomial encoding with column length sqrt(3).
% -> this means approx 3 values -> identifying constant-linear-effects
% -> when we have more samples we can encode to column length sqrt(n) and
% identify more interactions, but then the rr and rq formulae should be
% adapted accordingly

% NOTE: xl,xq init moved to top
% Polynomial coding
%xl = (samples-2).*sqrt(3./2);
%xq = (3.*(samples-2).^2-2)./sqrt(2);

mbest = size(F,2)-1; % start with initial kriging
m = mbest;
R = this.Rmatrix(usedIdx); % variance-covariance matrix of prior of beta

% Keep selecting variables until one of the stopping criteria is met...
nrIter = 3;
while (m-mbest) < nrIter && ... % stop when we don't improve over nrIter iterations
	  (length(this.idxTerms) < size(degrees,1)) && ...
	  ((m+1) < n) % Vandermonde matrix can't contain more interactions than #samples

	b = this.posteriorBeta(R,U);
	
	% multiple outputs -> take mean
	b = mean(b,2);
	b(this.idxTerms,:) = -Inf; % blank out already chosen terms
	
    [maxb idx] = max(b);
    m = m + 1;
    
	% keep hold of index in model matrix (for prediction)
    this.idxTerms = [this.idxTerms idx];
	
	% keep hold of interaction column to calculate new Blind Kriging model
    F(:,end+1) = U(:,idx);

	% intermediate model to asses
	if this.options.retuneParameters
        % update hyperparameters
        [this optimHp perf] = this.tuneParameters(F);
        
        hp = {this.options.rho0 this.options.lambda0 this.options.sigma20 this.hyperparameters0};
        hp(1,this.optimIdx) = mat2cell( optimHp, 1, this.optimNrParameters );
        this = this.updateModel(F, hp );
        
		R = this.Rmatrix(usedIdx); % variance-covariance matrix of prior of beta
	else
		% only regression part changed
        hp = [this.rho this.tau2 this.sigma2 this.hyperparameters];
		this = this.updateRegression( F, hp );
	end
    
	% asses BK
    scores = [scores ; feval(this.options.regressionMetric, this)];
	
	% check if the score of this model is better than of the previous ones
    if scores(end) < min( scores(1:end-1) )
        mbest = m;
    end
end

% first store the considered terms
this.stats.visitedDegrees = degrees( this.idxTerms, : );

% now we can cut off at mbest terms (+1 for intercept)
this.idxTerms = this.idxTerms(1:mbest+1);

% chosen terms
F = F(:,1:mbest+1);

%% estimate parameters again
% Always needed, there is no sane reason why it should be specified by
% user.
[this optimHp perf] = this.tuneParameters(F);

% construct model
hp = {this.options.rho0 this.options.lambda0 this.options.sigma20 this.hyperparameters0};
hp(1,this.optimIdx) = mat2cell( optimHp, 1, this.optimNrParameters );
this = this.updateModel(F, hp );

% Extra information
this.stats.scores = scores; % Cross-validated prediction errors
this.stats.scoreIndex = mbest + 1; % Chosen model index
this.stats.scoreFinal = feval(this.options.regressionMetric, this ); % Final score (after reoptimizing the parameters)

% no blind kriging anymore
this.regressionFcn = degrees( this.idxTerms, : ); % degrees of final BK model
this.options.regressionMetric = [];

this = this.cleanup();
end
