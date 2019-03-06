function [problem, params] = build_params_structure(fobj,X,y,lb,ub,max_eval,varargin)
% BUILD_PARAMS_STRUCTURE: Build an auxiliar structure used to keep 
% parameters used by the SAEA algorithm.
%
% Input:
%   fobj: handle to the objective function
%   X: Sample (rows are entries and coluns are the variables)
%   y: Evaluation of each row in X
%   lb: Lower bounds
%   ub: Upper bounds
%   max_eval: Budget of objective function evaluations
%
% Optional input (key/value pairs):
%   - EvolutionControl: Strategy used to control solutions.
%       Values: 'metamodel', 'random'.
%   - Metamodel: Type of metamodel.
%       Values: 'OrdinaryKriging', 'UniversalKriging1',
%       'UniversalKriging2', 'BlindKriging', 'RBF'.
%   - Optimizer: Algorithm used to optimize the metamodel parameters. It is
%       used with Kriging metamodels only.
%       Values: 'sqp', 'fmincon', 'ga'.
%   - RBF: Type of RBF function. It is used with RBF metamodel only.
%       Values: 'Gaussian', 'GaussianCrossValidation', 'Multiquadric'.
%
% Output:
%   params: A structure with fields that keep parameters used by the SAEA
%       (including toolboxes ooDACE and SRGTSToolbox).


% Sample size and number of variables
[init_sample_size, n] = size(X);

% Problem data
problem = struct();
problem.fobj = fobj;
problem.n = n;
problem.lb = lb;
problem.ub = ub;

% Parse optional input parameters
default_optimizer = 'sqp';
if n >= 20
    default_optimizer = 'fmincon';
end

parser = inputParser;
parser.addParameter('Verbose', true, @islogical);
parser.addParameter('EvolutionControl', 'metamodel', @ischar);
parser.addParameter('Metamodel', 'OrdinaryKriging_ooDACE', @ischar);
parser.addParameter('Optimizer', default_optimizer, @ischar);
parser.addParameter('RBF', 'Gaussian', @ischar);
parser.parse(varargin{:});

% Build parameters structure
params = struct();

% Budget of objective function evaluations
params.max_eval = max_eval;

% Parameters from parser
params.verbose = parser.Results.Verbose;
params.evolution_control = parser.Results.EvolutionControl;
params.metamodel = parser.Results.Metamodel;
params.optimizer = parser.Results.Optimizer;
params.rbf = parser.Results.RBF;

% Threshold values
params.tol_epsilon = 1e-1;
params.tol_ratio = 1e-6;
params.tol_std = 1e-6;

% Number of evaluations already spent
params.init_sample_size = init_sample_size;

% Set EA population size and Metamodel sample size
switch n
    case 2
        params.pop_size = 20;
        params.sample_size = 70;
    case 5
        params.pop_size = 20;
        params.sample_size = 70; 
    case 10
        params.pop_size = 20;
        params.sample_size = 70;
    case 15
        params.pop_size = 50;
        params.sample_size = 150;
    otherwise
        params.pop_size = 50;
        params.sample_size = 240;
end

if init_sample_size < params.sample_size
    error(strcat('Initial sample should have size(X,1)>=', ...
        int2str(params.sample_size), ' to be able to build the metamodel.'));
end

% Number of new solutions per solution at each iteration
params.offsprings_per_solution = 10;

% Set the maximum number of solution in the pool of solutions evaluated
% with the original objective function
params.max_pool_size = params.sample_size;

% ooDACE parameters
params.oodace = struct();
switch params.optimizer
    case 'sqp'  % SQPLabOptimizer
        params.oodace.hpOptimizer = SQPLabOptimizer(n,1);
    case 'fmincon'  % MATLAB fmincon optimizer
        params.oodace.GradObj = 'on';
        params.oodace.DerivativeCheck = 'off';
        params.oodace.Diagnostics = 'off';
        params.oodace.Algorithm = 'active-set';
        params.oodace.MaxFunEvals = 100*n;
        params.oodace.MaxIter = 100;
        params.oodace.TolFun = 1e-4;
        params.oodace.GradObj = 'off';
        params.oodace.hpOptimizer = MatlabOptimizer(n, 1, params.oodace);
    case 'ga' % MATLAB GA optimizer
        params.oodace.Display = 'off';
        params.oodace.Generations = 100;
        params.oodace.EliteCount = 2;
        params.oodace.CrossoverFraction = 0.8;
        params.oodace.PopInitRange = [-1;1];
        params.oodace.PopulationSize = 20;
        params.oodace.MigrationInterval = 20;
        params.oodace.MigrationFraction = 0.2;
        params.oodace.Vectorize = 'on';
        params.oodace.HybridFcn = [];
        params.oodace.MutationFcn = @mutationuniform;
        params.oodace.hpOptimizer = MatlabGA(n,1,params.oodace);
end

% SRGTSToolbox parameters
params.srgts = struct();
switch params.rbf
    case 'Gaussian'
        % RBF Metamodel with Gaussian base function with sigma=1
        params.srgts.P = X;
        params.srgts.T = y;        
        params.srgts.FIT_Fn = @rbf_build;
        params.srgts.RBF_type = 'G';
        params.srgts.RBF_c = 1;
        params.srgts.RBF_usePolyPart = 0;
        params.srgts.SRGT = 'RBF';
    case 'GaussianCrossValidation'
        % RBF Metamodel with Gaussian base function and sigma estimated by
        % cross validation
        params.srgts.P = X;
        params.srgts.T = y;
        params.srgts.FIT_Fn = @srgtsXVFit;
        params.srgts.RBF_type = 'G';
        params.srgts.RBF_usePolyPart = 0;
        params.srgts.SRGT = 'RBF';
        params.srgts.RBF_LowerBound = 1;
        params.srgts.RBF_UpperBound = 5;
    case 'Multiquadric'
        % RBF Metamodel with Multiquadric base function
        params.srgts = srgtsRBFSetOptions(X, y);
end

end