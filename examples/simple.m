% Clear all data
%clc
%clear all;
%close all;

% Add problem functions to the path
addpath('../experiments/problems');
addpath('../experiments/problems/analytic_functions');
addpath('../experiments/problems/cec2005');

% Load problem data
%problem = load_problem('rosen', 2);
%problem = load_problem('rosen', 5);
%problem = load_problem('elipsoid', 2);
%problem = load_problem('elipsoid', 5);
%problem = load_problem('ackley', 2);
%problem = load_problem('ackley', 5);
%problem = load_problem('shifted-rotated-rastrigin', 2);
%problem = load_problem('shifted-rotated-rastrigin', 5);
%problem = load_problem('schwefel', 5);
problem = load_problem('trid', 10);

fobj = problem.fobj;
lb = problem.lb;
ub = problem.ub;
n = problem.n;

% Budget of function evaluation
max_eval = 3000;

% Create initial sample
rng(3, 'twister');
ssize = 70;
X = lhsdesign(ssize, n);
X = repmat(lb, ssize, 1) + repmat(ub - lb, ssize, 1) .* X;
y = feval_all(fobj, X);


% Solve the problem
% [best_x, best_y, info] = surrogate_saea(fobj, X, y, lb, ub, max_eval);
%[best_x, best_y, info] = surrogate_saea(fobj, X, y, lb, ub, max_eval, 'Metamodel', 'OrdinaryKriging_ooDACE');
[best_x, best_y, info] = surrogate_saea(fobj, X, y, lb, ub, max_eval, 'Metamodel', 'UniversalKriging2_ooDACE');

% Print results
fprintf('\n\n')
fprintf('Best solution:\n');
fprintf('y = %.5f\n', best_y);
fprintf('x = ');
fprintf('%.5f ', best_x);
fprintf('\n');
fprintf('\n');
fprintf('Additional Information\n');
printstruct(info);
