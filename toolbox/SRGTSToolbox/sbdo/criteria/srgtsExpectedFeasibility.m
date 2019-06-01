function [EF EF_1 EF_2 EF_3 e] = srgtsExpectedFeasibility(zbar, yhat, sigma)

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% run

e      = 2*sigma;
zminus = zbar - e;
zplus  = zbar + e;

u      = (zbar   - yhat)./sigma;
uminus = (zminus - yhat)./sigma;
uplus  = (zplus  - yhat)./sigma;

EF_1 = (yhat - zbar).*(2*normcdf(u, 0, 1) - normcdf(uplus, 0, 1) - normcdf(uminus, 0, 1));
EF_2 = -sigma.*(2*normpdf(u, 0, 1) - normpdf(uplus, 0, 1) - normpdf(uminus, 0, 1));
EF_3 = e.*(normcdf(uplus, 0, 1) - normcdf(uminus, 0, 1));
EF = EF_1 + EF_2 + EF_3;

return
