function [model_info] = build_metamodel(sample_X, sample_y, lb, ub, type, params)
% BUILD_METAMODEL: Build an metamodel given sample_X and sample_y
%
% Input:
%   sample_X: The sample selected to build the metamodel (rows are entries 
%       and coluns are the variables)
%   sample_y: Evaluate of each row in sample_X
%   lb: Lower bounds
%   ub: Upper bounds
%   type: Type of metamodel
%   params: Structure containing ooDACE and SRGTSToolbox parameters.
%
% Output:
%   model_info: Structure with all information used by the metamodel


% Get ooDACE and SRGTSToolbox parameters
oodace_opts = params.oodace;
srgtstoolbox_opts = params.srgts;

model_info = [];
switch type
    case 'OrdinaryKriging_ooDACE'
        model_info = ordinary_kriging_oodace(sample_X, sample_y, lb, ub, oodace_opts);
        
    case 'UniversalKriging1_ooDACE'
        model_info = universal_kriging_1_oodace(sample_X, sample_y, lb, ub, oodace_opts);
        
   case 'UniversalKriging2_ooDACE'
        model_info = universal_kriging_2_oodace(sample_X, sample_y, lb, ub, oodace_opts);
        
    case 'BlindKriging_ooDACE'
        model_info = blind_kriging_oodace(sample_X, sample_y, lb, ub, oodace_opts);     
        
    case 'RBF_SRGTSToolbox'
        model_info = rbf_SRGTSToolbox(sample_X, sample_y, lb, ub, srgtstoolbox_opts, params.rbf);

    case 'OrdinaryKriging_SRGTSToolbox'
        model_info = ordinary_kriging_SRGTSToolbox(sample_X, sample_y, lb, ub);

    case 'UniversalKriging1_SRGTSToolbox'
        model_info = universal_kriging_1_SRGTSToolbox(sample_X, sample_y, lb, ub);
        
    case 'UniversalKriging2_SRGTSToolbox'
        model_info = universal_kriging_2_SRGTSToolbox(sample_X, sample_y, lb, ub);
end

end


% =========================================================================
% Auxiliary functions
% =========================================================================

% Ordinary Kriging Metamodel using ooDACE Toolbox
function model_info = ordinary_kriging_oodace(sample_X, sample_y, lb, ub, oodace_opts)
    
% Set some settings
oodace_opts.type = 'Kriging';          
oodace_opts.regrFunc = ''; % It seems that 'regpoly0' option is not properly working.
oodace_opts.filterBySumDegrees = true; % Adaptation on ooDACe to choose base functions
oodace_opts.corrFunc = @corrgauss; % Correlation function
oodace_opts.hp0 = repmat(0.5, 1, length(lb));% Initial hyperparameter
oodace_opts.hpBounds = [repmat(-2, 1, length(lb)) ; repmat(2, 1, length(lb))]; % Bounds of the hyperparameters

% Build a metamodel
ModelooDACE = oodacefit(sample_X, sample_y, oodace_opts);

% Get the metamodel
model_info.ooDACE = ModelooDACE;
model_info.Sample = ModelooDACE.getSamples;
model_info.EvalSample = ModelooDACE.getValues;
model_info.Theta = ModelooDACE.getHyperparameters;
model_info.Lower = lb;
model_info.Upper = ub;
model_info.p = 2*ones(1,length(lb));
model_info.LowerBoundTheta = oodace_opts.hpBounds(1,:);
model_info.UpperBoundTheta = oodace_opts.hpBounds(2,:);
model_info.fobjPredicao = @(x)(pred_ooDACE(x,model_info.ooDACE)); 
model_info.fobjEI = @(x)(expimp_ooDACE(x,model_info));
end


% Universal Kriging Metamodel (power 1) using ooDACE Toolbox
function model_info = universal_kriging_1_oodace(sample_X, sample_y, lb, ub, oodace_opts)
    
% Set some settings
oodace_opts.type = 'Kriging';          
oodace_opts.regrFunc = 'regpoly1';
oodace_opts.filterBySumDegrees = true; % Adaptation on ooDACe to choose base functions
oodace_opts.corrFunc = @corrgauss; % Correlation function
oodace_opts.hp0 = repmat(0.5, 1, length(lb));% Initial hyperparameter
oodace_opts.hpBounds = [repmat(-2, 1, length(lb)) ; repmat(2, 1, length(lb))]; % Bounds of the hyperparameters

% Build a metamodel
ModelooDACE = oodacefit(sample_X, sample_y, oodace_opts );

% Get the metamodel
model_info.ooDACE = ModelooDACE;
model_info.Sample = ModelooDACE.getSamples;
model_info.EvalSample = ModelooDACE.getValues;
model_info.Theta = ModelooDACE.getHyperparameters;
model_info.Lower = lb;
model_info.Upper = ub;
model_info.p = 2*ones(1,length(lb));
model_info.LowerBoundTheta = oodace_opts.hpBounds(1,:);
model_info.UpperBoundTheta = oodace_opts.hpBounds(2,:);
model_info.fobjPredicao = @(x)(pred_ooDACE(x,model_info.ooDACE)); 
model_info.fobjEI = @(x)(expimp_ooDACE(x,model_info));
end


% Universal Kriging Metamodel (power 2) using ooDACE Toolbox
function model_info = universal_kriging_2_oodace(sample_X, sample_y, lb, ub, oodace_opts)
    
% Set some settings
oodace_opts.type = 'Kriging';          
oodace_opts.regrFunc = 'regpoly2';
oodace_opts.filterBySumDegrees = true; % Adaptation on ooDACe to choose base functions
oodace_opts.corrFunc = @corrgauss; % Correlation function
oodace_opts.hp0 = repmat(0.5, 1, length(lb));% Initial hyperparameter
oodace_opts.hpBounds = [repmat(-2, 1, length(lb)) ; repmat(2, 1, length(lb))]; % Bounds of the hyperparameters

% Build a metamodel
ModelooDACE = oodacefit(sample_X, sample_y, oodace_opts );

% Get the metamodel
model_info.ooDACE = ModelooDACE;
model_info.Sample = ModelooDACE.getSamples;
model_info.EvalSample = ModelooDACE.getValues;
model_info.Theta = ModelooDACE.getHyperparameters;
model_info.Lower = lb;
model_info.Upper = ub;
model_info.p = 2*ones(1,length(lb));
model_info.LowerBoundTheta = oodace_opts.hpBounds(1,:);
model_info.UpperBoundTheta = oodace_opts.hpBounds(2,:);
model_info.fobjPredicao = @(x)(pred_ooDACE(x,model_info.ooDACE)); 
model_info.fobjEI = @(x)(expimp_ooDACE(x,model_info));
end


% Blind Kriging Metamodel using ooDACE Toolbox
function model_info = blind_kriging_oodace(sample_X, sample_y, lb, ub, oodace_opts) 
oodace_opts.type = 'BlindKriging'; 
oodace_opts.retuneParameters = true; 
oodace_opts.corrFunc = @corrgauss; % Correlation function
oodace_opts.hp0 = repmat(0.5, 1, length(lb));% Initial hyperparameter
oodace_opts.hpBounds = [repmat(-2, 1, length(lb)) ; repmat(2, 1, length(lb))]; % Bounds of the hyperparameters

% Build metamodel               
ModelooDACE = oodacefit(sample_X, sample_y, oodace_opts);

% Get metamodel
model_info.ooDACE = ModelooDACE;
model_info.Sample = ModelooDACE.getSamples;
model_info.EvalSample = ModelooDACE.getValues;
model_info.Theta = ModelooDACE.getHyperparameters;
model_info.Lower = lb;
model_info.Upper = ub;
model_info.p = 2*ones(1,length(lb));
model_info.LowerBoundTheta = oodace_opts.hpBounds(1,:);
model_info.UpperBoundTheta = oodace_opts.hpBounds(2,:);
model_info.fobjPredicao = @(x)(pred_ooDACE(x,model_info.ooDACE)); 
model_info.fobjEI = @(x)(expimp_ooDACE(x,model_info));
end


% RBF Metamodel using SRGTSToolbox
function model_info = rbf_SRGTSToolbox(sample_X, sample_y, lb, ub, srgtstoolbox_opts,type_rbf)
switch type_rbf
    case 'Gaussian'
        % RBF Metamodel with Gaussian base function with sigma=1
        srgtstoolbox_opts.P = sample_X;
        srgtstoolbox_opts.T = sample_y;
        
    case 'GaussianCrossValidation'
        % RBF Metamodel with Gaussian base function and sigma estimated by
        % cross validation
        srgtstoolbox_opts.P = sample_X;
        srgtstoolbox_opts.T = sample_y;
        
    case 'Multiquadric'
        % RBF Metamodel with Multiquadric base function
        srgtstoolbox_opts = srgtsRBFSetOptions(sample_X, sample_y);
end

[ModeloSRTSToolbox] = srgtsRBFFit(srgtstoolbox_opts);
model_info.SRTSToolbox = ModeloSRTSToolbox;
model_info.fobjPredicao = @(x)(srgtsRBFEvaluate(x,model_info.SRTSToolbox));

end


% Ordinary Kriging Metamodel using SRGTSToolbox
function model_info = ordinary_kriging_SRGTSToolbox(sample_X, sample_y, lb, ub)

[N,n] = size(sample_X);
FIT_Fn = @dace_fit;
KRG_RegressionModel = @dace_regpoly0; 
KRG_CorrelationModel = @dace_corrgauss;
KRG_Theta0 = (N.^(-1/n))*ones(1, n);
LowerBound = ones(1,n).*(-3);
UpperBound = ones(1,n).*2;
KRG_LowerBound = 10.^LowerBound;  % lower bound theta
KRG_UpperBound = 10.^UpperBound;  % upper bound theta
srgtstoolbox_opts  = srgtsKRGSetOptions(sample_X, sample_y,FIT_Fn, KRG_RegressionModel, KRG_CorrelationModel, KRG_Theta0, KRG_LowerBound, KRG_UpperBound);
[ModeloSRTSTolbox] = srgtsKRGFit(srgtstoolbox_opts);  
model_info.SRTSToolbox = ModeloSRTSTolbox;
model_info.Theta = ModeloSRTSTolbox.KRG_DACEModel.theta; % Here, theta is 10.^Theta
model_info.Lower = lb;
model_info.Upper = ub;
model_info.p = 2*ones(1,length(lb));     
model_info.fobjPredicao = @(x)(srgtsKRGEvaluate(x,model_info.SRTSToolbox));

end


% Universal Kriging Metamodel (power 1) using SRGTSToolbox
function model_info = universal_kriging_1_SRGTSToolbox(sample_X, sample_y, lb, ub)

[N,n] = size(sample_X);
FIT_Fn = @dace_fit;
KRG_RegressionModel = @dace_regpoly1; 
KRG_CorrelationModel = @dace_corrgauss;
KRG_Theta0 = (N.^(-1/n))*ones(1, n);
LowerBound = ones(1,n).*(-3);
UpperBound = ones(1,n).*2;
KRG_LowerBound = 10.^LowerBound;  % lower bound theta
KRG_UpperBound = 10.^UpperBound;  % upper bound theta
srgtstoolbox_opts  = srgtsKRGSetOptions(sample_X, sample_y,FIT_Fn, KRG_RegressionModel, KRG_CorrelationModel, KRG_Theta0, KRG_LowerBound, KRG_UpperBound);
[ModeloSRTSTolbox] = srgtsKRGFit(srgtstoolbox_opts);  
model_info.SRTSToolbox = ModeloSRTSTolbox;
model_info.Theta = ModeloSRTSTolbox.KRG_DACEModel.theta; % Here, theta is 10.^Theta
model_info.Lower = lb;
model_info.Upper = ub;
model_info.p = 2*ones(1,length(lb));     
model_info.fobjPredicao = @(x)(srgtsKRGEvaluate(x,model_info.SRTSToolbox));

end


% Universal Kriging Metamodel (power 2) using SRGTSToolbox
function model_info = universal_kriging_2_SRGTSToolbox(sample_X, sample_y, lb, ub)

[N,n] = size(sample_X);
FIT_Fn = @dace_fit;
KRG_RegressionModel = @dace_regpoly2;  
KRG_CorrelationModel = @dace_corrgauss;
KRG_Theta0 = (N.^(-1/n))*ones(1, n);
LowerBound = ones(1,n).*(-3);
UpperBound = ones(1,n).*2;
KRG_LowerBound = 10.^LowerBound;  % lower bound theta
KRG_UpperBound = 10.^UpperBound;  % upper bound theta
srgtstoolbox_opts  = srgtsKRGSetOptions(sample_X, sample_y,FIT_Fn, KRG_RegressionModel, KRG_CorrelationModel, KRG_Theta0, KRG_LowerBound, KRG_UpperBound);
[ModeloSRTSTolbox] = srgtsKRGFit(srgtstoolbox_opts);  
model_info.SRTSToolbox = ModeloSRTSTolbox;
model_info.Theta = ModeloSRTSTolbox.KRG_DACEModel.theta; % Here, theta is 10.^Theta
model_info.Lower = lb;
model_info.Upper = ub;
model_info.p = 2*ones(1,length(lb));     
model_info.fobjPredicao = @(x)(srgtsKRGEvaluate(x,model_info.SRTSToolbox));

end
