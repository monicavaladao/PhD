% Clear all data
%clc
%clear all;
%close all;

% Add problem functions to the path
addpath('./problems');
addpath('./problems/analytic_functions');
addpath('./problems/cec2005');

% Load problem data
problem = load_problem('rosen', 2);
%problem = load_problem('shifted-rotated-rastrigin', 2);
%problem = load_problem('shifted-rotated-rastrigin', 5);

fobj = problem.fobj;
lb = problem.lb;
ub = problem.ub;
n = problem.n;

% Budget of function evaluation
max_eval = 500;

% Initial sample
N0 = 70;
X = repmat(lb, N0, 1) + rand(N0, n) .* repmat(ub - lb, N0, 1);
y = feval_all(fobj, X);

% Solve the problem
% [best_x, best_y, info] = surrogate_saea(fobj, X, y, lb, ub, max_eval);
[best_x, best_y, info] = surrogate_saea(fobj, X, y, lb, ub, max_eval, 'Metamodel', 'OrdinaryKriging_ooDACE');

% Print results
fprintf('\n\n')
fprintf('Best solution:\n');
fprintf('y = %.5f\n', best_y);
fprintf('x = ', best_x);
fprintf('%.5f ', best_x);
fprintf('\n');
fprintf('\n');
fprintf('Additional Information\n');
printstruct(info);
