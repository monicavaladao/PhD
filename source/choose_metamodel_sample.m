function [X,y] = choose_metamodel_sample(pool,sample_size, std_tol)
% CHOOSE_METAMODEL_SAMPLE: Choose a sample to create/update the metamodel.
% This function chooses the newest solutions into the pool to compose the
% sample.
%
% Input: 
%   pool: Pool of solutions.
%   sample_size: Metamodel sample size.
%   std_tol: 
% 
% Output:
%   sample_X: The sample selected to build the metamodel (rows are entries 
%       and coluns are the variables).
%   sample_y: Evaluate of each row in sample_X.
% 

% Sort solutions by their age
[~,idx] = sort(pool.age,'descend');
auxpool_X = pool.X(idx,:);
auxpool_y = pool.y(idx);
 
% Select the sample_size newest solution
X = auxpool_X(1:sample_size,:);
y = auxpool_y(1:sample_size);
 
% Number of solutions in the pool
pool_size = size(auxpool_X,1);

% If standart deviation of X or y is zero, then the metamodel sample must be redefined.
while (any(std(X) < std_tol) || any(isnan(std(X))) || std(y) < std_tol || isnan(std(y))) && sample_size < pool_size
    sample_size = sample_size + 1;
    X = auxpool_X(1:sample_size,:);
    y = auxpool_y(1:sample_size);
end

end