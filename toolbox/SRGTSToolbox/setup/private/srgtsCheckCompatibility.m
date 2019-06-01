function [b_isversionok, interpreter, interpreterversion, minimunversion] = srgtsCheckCompatibility(toolboxversion)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Felipe A. C. Viana
% felipeacviana@gmail.com
% http://sites.google.com/site/felipeacviana
%
% This program is free software; you can redistribute it and/or
% modify it. This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% version information about interpreter (MATLAB or OCTAVE)
aux = ver;
if strcmp(aux(1).Name, 'Octave')
    interpreter = 'OCTAVE';
    minimunversion = '3.2';
    interpreterversion = ver(interpreter);
    interpreterversion.Release = '';
    b_isversionok = (str2num(interpreterversion.Version(1:3)) >= str2num(minimunversion));
else
    interpreter = 'MATLAB';
    minimunversion = '6.5';
    interpreterversion = ver(interpreter);
    b_isversionok = (str2num(interpreterversion.Version) >= str2num(minimunversion));
end

if (b_isversionok == false)
    str = sprintf('ERROR:\n%s %s requires at least %s %s',...
        toolboxversion.Name,...
        toolboxversion.Version,...
        interpreter, ...
        minimunversion);
    disp(str)
end

return
