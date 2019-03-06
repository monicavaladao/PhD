function [] = launch(problem, metamodel, rep, filename)

% Get problem data
n = problem.n;
lb = problem.lb;
ub = problem.ub;
fobj = problem.fobj;
npop = problem.npop;
neval = problem.neval;

% Create initial sample
rng(rep, 'twister');
ssize = 5 * npop;
X = lhsdesign(ssize, n);
X = repmat(lb, ssize, 1) + repmat(ub - lb, ssize, 1) .* X;
y = feval_all(fobj, X);

% Solve the problem
[best_x, best_y, info] = surrogate_saea(fobj, X, y, lb, ub, neval, metamodel.params{:});

% Save results
if ~exist('results', 'dir')
    mkdir('results');
end

fid = fopen(filename, 'w+');
fprintf(fid, 'METAMODEL,PROB,NVAR,REP,NEVAL,ITER,BEST.OBJ,MEAN.DIFF,METAMODEL.TIME.S,TOTAL.TIME.S\n');

history = info.history;
for i = 1:length(history.iterations)
    fprintf(fid, '"%s","%s",%d,%d,%d,%d,%.6f,%.6f,%.6f,%.6f\n', ...
        metamodel.name, problem.name, n, rep, history.neval(i), ...
        history.iterations(i), history.best_y(i), history.mean_diff(i), ...
        history.metamodel_runtime(i), history.saea_runtime(i));
end

fclose(fid);

end

