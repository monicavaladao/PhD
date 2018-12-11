function [f] = elipsoid(x)


d = length(x);

sum = 0;
for i = 1:d
    sum = sum + i*x(i)^(2);
end

f = sum;
   

end