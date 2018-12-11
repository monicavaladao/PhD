% Clear MATLAB workspace
clear all
close all
clc

% Add problem functions to the path
addpath('./problems');
addpath('./problems/analytic_functions');
addpath('./problems/cec2005');

% Load metamodels
metamodels = struct();

metamodels(1).name = 'ordinary-kriging';
metamodels(1).params = {'Metamodel', 'OrdinaryKriging_ooDACE', 'Verbose', false};

metamodels(2).name = 'rbf-gaussian';
metamodels(2).params = {'Metamodel', 'RBF', 'RBF', 'Gaussian', 'Verbose', false};

% Load problems
%npop = [20 20 20 50 50 50];
npop = [50 50];
%nvars = [2, 5, 10, 20, 30, 50];
nvars = [30, 50];
%neval = [1000 2000 3000 5000 5000 5000];
neval = [500 500];
%problem_names = {'ackley', 'elipsoid', 'griewank', 'rosen'};
problem_names = {'ackley', 'elipsoid'};

idx = 1;
problems = struct();
for i = 1:length(problem_names)
    for j = 1:length(nvars)
        aux = load_problem(problem_names{i}, nvars(j));
        problems(idx).name = problem_names{i};
        problems(idx).n = aux.n;
        problems(idx).lb = aux.lb;
        problems(idx).ub = aux.ub;
        problems(idx).fobj = aux.fobj;
        problems(idx).npop = npop(j);
        problems(idx).neval = neval(j);
        idx = idx + 1;
    end
end

% Other settings
repetitions = 1;

% Launch algorithms (in parallel)
c = parcluster();
jobs = {};
for rep = 1:repetitions
    for i = 1:length(metamodels)
        for j = 1:length(problems)
            filename = sprintf('.results/%s-%s-%02d-%02d.csv', metamodels(i).name, problems(j).name, problems(j).n, rep);
            if ~exist(filename, 'file')
                fprintf('Launching... %s -> %s (%d nvars) -> Rep. %d\n', metamodels(i).name, problems(j).name, problems(j).n, rep);
                %launch(problems(j), metamodels(i), rep);
                job = batch(c, @launch, 0, {problems(j), metamodels(i), rep});
                jobs = [jobs, {job}];
            end
        end
    end
end

%for i = 1:length(jobs)
%    wait(jobs{i});
%    delete(jobs{i});
%end
