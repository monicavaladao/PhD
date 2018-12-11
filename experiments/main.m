% Clear MATLAB workspace
clear all
close all
clc

% -------------------------------------------------------------------------
% Add problem functions to the path

addpath('./problems');
addpath('./problems/analytic_functions');
addpath('./problems/cec2005');


% -------------------------------------------------------------------------
% Repetitions of the experiment

repetitions = 10;


% -------------------------------------------------------------------------
% Metamodel to evaluate

metamodels = struct();

metamodels(1).name = 'ordinary-kriging';
metamodels(1).params = {'Metamodel', 'OrdinaryKriging_ooDACE', 'Verbose', false};

metamodels(2).name = 'universal-kriging1';
metamodels(2).params = {'Metamodel', 'UniversalKriging1_ooDACE', 'Verbose', false};

metamodels(3).name = 'universal-kriging2';
metamodels(3).params = {'Metamodel', 'UniversalKriging2_ooDACE', 'Verbose', false};

metamodels(4).name = 'blind-kriging';
metamodels(4).params = {'Metamodel', 'BlindKriging_ooDACE', 'Verbose', false};

metamodels(5).name = 'rbf-gaussian';
metamodels(5).params = {'Metamodel', 'RBF', 'RBF', 'Gaussian', 'Verbose', false};


% -------------------------------------------------------------------------
% Problems to solve

% nvars = [2, 5, 10, 20, 30, 50];
% npop = [20 20 20 50 50 50];
% neval = [1000 2000 3000 5000 5000 5000];

nvars = [2, 5, 10, 20];
npop = [20 20 20 50];
neval = [1000 2000 3000 5000];

problem_names = {'ackley', 'elipsoid', 'griewank', 'rosen', 'shifted-rotated-rastrigin'};

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


% -------------------------------------------------------------------------
% Entries (tuples <problem x metamodel x repetition>)

idx = 1;
for rep = 1:repetitions
    for i = 1:length(metamodels)
        for j = 1:length(problems)
            filename = sprintf('./results/%s-%s-%02d-%02d.csv', metamodels(i).name, problems(j).name, problems(j).n, rep);
            if ~exist(filename, 'file')
                entry = struct();
                entry.filename = filename;
                entry.metamodel = metamodels(i);
                entry.problem = problems(j);
                entry.rep = rep;
                entries(idx) = entry;
                idx = idx + 1;
            end
        end
    end
end


% -------------------------------------------------------------------------
% Launch algorithms (in parallel)

c = parcluster();  % cluster
p = parpool(c);    % pool
for i = 1:length(entries)
    f(i) = parfeval(p, @launch, 0, entries(i).problem, ...
        entries(i).metamodel, entries(i).rep, entries(i).filename);
end

% Wait for all parallel jobs to finish
for i = 1:length(f)
    try
        [idx] = fetchNext(f);
        fprintf('Completed: %s (%d vars) using %s metamodel (rep. %d)\n', ...
            entries(idx).problem.name, entries(idx).problem.n, ...
            entries(idx).metamodel.name, entries(idx).rep);
    catch ex
        warning(ex.message);
    end
end

% Release parallel resources
delete(p);


% -------------------------------------------------------------------------
% Get all results together

% List of files with individual results
files = ls('./results/*.csv');

% Write file with all results
fid = fopen('all.csv', 'w+');
fprintf(fid, 'METAMODEL,PROB,NVAR,REP,NEVAL,ITER,BEST.OBJ,MEAN.DIFF,METAMODEL.TIME.S,TOTAL.TIME.S\n');

for i = 1:size(files, 1)
    filename = strcat('./results/', files(i,:));
    cfid = fopen(filename, 'r');
    cline = fgetl(cfid); % ignore CSV header
    cline = fgetl(cfid); % first line after header
    while ischar(cline) && ~isempty(cline)
        fprintf(fid, cline); % write line
        fprintf(fid, '\n');
        cline = fgetl(cfid); % read next line
    end
    fclose(cfid);
end

fclose(fid);
