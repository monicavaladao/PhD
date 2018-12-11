function y = feval_all(fobj, X)
% FEVAL_ALL: Evaluate each column in X on fobj.

% Number of entries to evaluate
[N,~] = size(X);

% Evaluate all entries
y = zeros(N, 1);
for i = 1:N
    y(i,1) = feval(fobj, X(i,:));
end

end