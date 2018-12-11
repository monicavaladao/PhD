function [best_x, best_y, info] = surrogate_saea(fobj, X, y, lb, ub, max_eval, varargin)
% SURROGATE_SAEA: Surrogate Assisted Evolutionary Algorithm  build over
% ooDACE toolbox and SRGTS toolbox.
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
%   best_x: Best solution found.
%   best_y: Objective value of the best solution found.
%   info: A structure with additional information.
%
% References:
% [1] xxx


% Start timer
t0_start = cputime;

% Initialize structures used by the SAEA
[problem, params] = build_params_structure(fobj, X, y, lb, ub, max_eval, varargin{:});
info = build_info_structure(X, y, problem, params);

% Get some parameters
n = problem.n;          % Number of variables
N = params.pop_size;    % Population size of the EA

% Find the current best solution
[value, idx] = min(y);
info.best_x = X(idx,:);
info.best_y = value;

% Update stats
info.history.iterations = [0];
info.history.best_x = [info.best_x];
info.history.best_y = [info.best_y];
info.history.neval = [info.neval];
info.history.mean_diff = [0];
info.history.metamodel_runtime = [0];
info.history.saea_runtime = [0];

% Select the initial population
[pop_X, pop_y] = select_initial_population(X, y, N);
idx_best = 1;

% Logging
if params.verbose
    fprintf('-------------------------------------------------------------------------- \n');
    fprintf(' Iterations |      Best Obj. | Fun.Eval. |     Mean Diff. |    Runtime (s) \n');
    fprintf('-------------------------------------------------------------------------- \n')
    fprintf('% 11d | % 14.5f | % 9d |            --- | % 14.5f \n', 0, ...
        info.best_y, info.neval, (cputime - t0_start));
end

% Initialize counters
eval_counter = info.neval;
iter_counter = 1;

while eval_counter < params.max_eval
    
    % Find the best solution in pop_X
    best_x = pop_X(idx_best, :);
    
    % Create offspring solutions using DE/best/1 operators
    P = create_offsprings_de_best(pop_X, best_x, lb, ub, params.offsprings_per_solution);
    
    % Select a sample to build/update the metamodel
    [sample_X, sample_y] = choose_metamodel_sample(info.pool, params.sample_size, params.tol_std);
    
    % Build the metamodel
    tt0_start = cputime;
    model_info = build_metamodel(sample_X, sample_y, lb, ub, params.metamodel, params);
    tt0_end = cputime - tt0_start;
    
    info.history.metamodel_runtime = [info.history.metamodel_runtime, tt0_end];
    info.metamodel = model_info;
    
    % Choose N solutions from P (one solution per subpopulation)
    [chosen_X, others_X, chosen_pred] = select_solutions(P, N, n, lb, ub, params.evolution_control, model_info.fobjPredicao);
    
    % Evaluate chosen solution with the original function
    neval = min(N, params.max_eval - eval_counter);
    
    if (eval_counter + N) >= params.max_eval
        
        % Evaluate solutions with the original function
        idx_eval = randperm(N, neval);
        chosen_X = chosen_X(idx_eval,:);
        chosen_y = feval_all(problem.fobj, chosen_X);
        chosen_pred = chosen_pred(idx_eval);
        
    else
        
        % Evalute solutions with the original function
        chosen_y = feval_all(problem.fobj, chosen_X);
        
        % Choose the popoutaion of the next iteration
        [pop_X, pop_y, idx_best] = select_population(pop_X, pop_y, chosen_X, chosen_y);
        
    end
    
    % Update the evaluation counter
    info.neval = info.neval + neval;
    eval_counter = eval_counter + neval;

    % Update the pool of solutions
    info.pool = update_pool(pop_X, chosen_X, chosen_y, info.pool, params);

    % Update best solution
    aux_X = [info.best_x; chosen_X];
    aux_y = [info.best_y; chosen_y];
    [value, idx] = min(aux_y);
    info.best_x = aux_X(idx,:);
    info.best_y = value;

    % Update the history
    info.history.iterations = [info.history.iterations, iter_counter];
    info.history.neval = [info.history.neval, info.neval];
    info.history.best_x = [info.history.best_x; info.best_x];
    info.history.best_y = [info.history.best_y, info.best_y];
    info.history.mean_diff = [info.history.mean_diff, mean(abs(chosen_pred - chosen_y))];
    info.history.saea_runtime = [info.history.saea_runtime, cputime - t0_start];
    
    % Logging
    if params.verbose
        if info.history.best_y(end) < info.history.best_y(end-1)
            flag = '*';
        else
            flag = '';
        end
        fprintf('%1s% 10d | % 14.5f | % 9d | % 14.5f | % 14.5f \n', ...
            flag, iter_counter, info.best_y, info.neval, ...
            mean(abs(chosen_pred - chosen_y)), (cputime - t0_start));
    end
    
    % Update iteration counter
    iter_counter = iter_counter + 1;
    
end

best_x = info.best_x;
best_y = info.best_y;

end