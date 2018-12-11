function [exp_improv,y] = expimp_ooDACE(x,info)
% EXPIMP_OODACE: Adapt "expimp" frunction from Alexander Forrester [1] to
% calculate the expected improvement using the metamodel built with ooDACE
% Toolbox.
%
% Input:
%   x:
%   info:
%
% Output:
%   exp_improv:
%   y:
%
% References:
%   [1] FORESTER, Alexander. .....


% Get metamodel info
X = info.Sample;
y = info.EvalSample;

% Best point in X so far
y_min = min(y);

% Prediction and MSE
[y, dy, mse, dmse] = predictor(x, info.ooDACE);
y_hat = y;

% Expected Improvement
if mse == 0
    exp_improv = 0;
else
    ei_termone = (y_min - y_hat)*(0.5 + 0.5*erf((1/sqrt(2))*...
        ((y_min - y_hat)/sqrt(abs(mse)))));

    ei_termtwo = sqrt(abs(mse))*(1/sqrt(2*pi))*exp(-(1/2)*...
        ((y_min - y_hat)^2/mse));
    
    exp_improv = ei_termone + ei_termtwo;
end

end