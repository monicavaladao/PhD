function  [F X] = ecdf(Y)
%Function ecdf estimates of the cumulative distribution function (cdf),
%also known as the empirical cdf. Thus, for example:
%
%    [F X] = ecdf(Y): Y is a vector of data values. F is a vector of values
%    of the empirical cdf evaluated at X.
%
%Example:
%     % sample data
%     Y = [10.1668 18.4077 22.1693  3.8285  6.8238  7.0560, ...
%          23.5143  6.5171  5.9652 17.2127 15.8627 22.2182]';
%
%     [F X] = ecdf(Y)
%
%     F =
% 
%        0.00000
%        0.08333
%        0.16667
%        0.25000
%        0.33333
%        0.41667
%        0.50000
%        0.58333
%        0.66667
%        0.75000
%        0.83333
%        0.91667
%        1.00000
% 
%     X =
% 
%         3.8285
%         3.8285
%         5.9652
%         6.5171
%         6.8238
%         7.0560
%        10.1668
%        15.8627
%        17.2127
%        18.4077
%        22.1693
%        22.2182
%        23.5143

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

% [F,X] = ECDF(Y) 

[n m] = size(Y);
if n < m
    Y = Y';
end

X = sort(Y);
F = [0; empirical_cdf(X,X)];
X = [X(1); X];

return