function flag = srgtsSBDOCheckDataSet(X, npoints, nvar)
% flag is equal to one if all points are different

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Felipe A. C. Viana
% felipeacviana@gmail.com
% http://sites.google.com/site/felipeacviana
%
% This program is free software; you can redistribute it and/or
% modify it. This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Normalize data
mX = mean(X);   sS = std(X);
j = find(sS == 0);
if  ~isempty(j)
    sS(j) = 1;
end

X = (X - repmat(mX,npoints,1)) ./ repmat(sS,npoints,1);

% Calculate distances D between points
mzmax = npoints*(npoints - 1) / 2;        % number of non-zero distances
D = zeros(mzmax, nvar);        % initialize matrix with distances
ll = 0;
for k = 1 : npoints-1
    ll = ll(end) + (1 : npoints-k);
    D(ll,:) = repmat(X(k,:), npoints-k, 1) - X(k+1:npoints,:); % differences between points
end

flag = min(sum(abs(D),2)) ~= 0;

return
