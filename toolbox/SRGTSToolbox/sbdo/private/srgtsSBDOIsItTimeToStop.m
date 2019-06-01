function [timeToStop reason] = srgtsSBDOIsItTimeToStop(KRG_DACEModel, iter, maxNbCycles)

timeToStop = iter >= maxNbCycles;
reason     = sprintf('Maximum number of cycles was reached.');

if ~timeToStop
    for c1 = 1 : length(KRG_DACEModel)
        krgbeta = sum(KRG_DACEModel.beta);
        if isnan(krgbeta)
            timeToStop = 1;
            reason = sprintf('KRG model # %d crashed.', c1);
        end
    end
end

return
