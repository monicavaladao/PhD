function f = sasena(x, opt)
% sasena.m This function returns the function value of the sasena function,
% given by:
%
%       f(x) = 2 + 0.01*(x2 - x1^2)^2 + (1 - x1)^2 + 2*(2 - x2)^2 +
%       7*sin(0.5*x1)*sin(0.7*x1*x2)

% opt must be 2 for original definition of the sasena's function

f = opt + ...
    0.01*(x(:,2) - x(:,1).^2).^2 + ...
    (1 - x(:,1)).^2 + ...
    2*(2 - x(:,2)).^2 + ...
    7*sin(0.5*x(:,1)).*sin(0.7*x(:,1).*x(:,2));
