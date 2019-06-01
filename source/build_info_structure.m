function [info] = build_info_structure(X, y, problem, params)
% BUILD_INFO_STRUCTURE: Build a structure used to keep the progress of the 
% SAEA algorithm.
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
%       'UniversalKriging2', 'RBF'.
%   - Optimizer: Algorithm used to optimize the metamodel parameters. It is
%       used with Kriging metamodels only.
%       Values: 'sqp', 'fmincon', 'ga'.
%   - RBF: Type of RBF function. It is used with RBF metamodel only.
%       Values: 'Gaussian', 'GaussianCrossValidation', 'Multiquadric'.
%
% Output:
%   info: A structure with fields that keep the settings used by the SAEA
%       (including toolboxes), and fields that keep the evolution of the 
%       algorithm.

% Build info structure
info = struct();

% Keep problem data and algorithm parameters
info.problem = problem;
info.params = params;

% Best solution
info.best_x = [];
info.best_y = []; 

% Metamodel data
info.metamodel = struct([]);

% Keep the progress of the algorithm
info.history.iterations = [];
info.history.best_x = [];
info.history.best_y = [];
info.history.neval = [];
info.history.mean_diff = [];
info.history.metamodel_runtime = [];
info.history.saea_runtime = [];

% Total number of evaluations
info.neval = params.init_sample_size;

% Pool of solutions
info.pool.next_age = 2;
if params.max_pool_size < params.init_sample_size
    [~,idx] = sort(y,'ascend');
    info.pool.X = X(idx(1:info.params.max_pool_size),:);
    info.pool.y = y(idx(1:info.params.max_pool_size));
    info.pool.age = ones(info.params.max_pool_size,1);
else
    info.pool.X = X;
    info.pool.y = y;
    info.pool.age = ones(size(X,1),1);
end

end

