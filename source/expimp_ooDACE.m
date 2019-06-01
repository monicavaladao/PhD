function [exp_improv,y] = expimp_ooDACE(x,info)
% EXPIMP_OODACE: Adapt "expimp" function from Alexander Forrester [1] to
% calculate the expected improvement using the metamodel built with ooDACE
% Toolbox.
%
% Input:
%   x: vetor of design variables
%   info: Structure with all information used by the metamodel
%
% Output:
%   exp_improv: Scalar Expected Improvement
%   y: Scalar Kriging prediction
%
% References:
%   [1] Forrester, A.I.J., Sóbester, A., Keane, A.J.: Engineering Design
%   via Surrogate Modelling: A Practical Guide. John Wiley & Sons (2008)


% Get metamodel info
X = info.Sample;
y = info.EvalSample;

% Best point in X so far
y_min = min(y);

% Prediction and MSE
[y_hat, dy, mse, dmse] = predictor(x, info.ooDACE);


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