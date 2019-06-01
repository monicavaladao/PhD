function score = braninhoo(x)

x1 = x(:,1);
x2 = x(:,2);

score = ( x2 - 5.1*(x1.^2)/(4*pi^2) + 5*x1/pi - 6).^2 + ...
        10*(1 - 1/(8*pi))*cos(x1) + 10;

return
