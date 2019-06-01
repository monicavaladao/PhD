function b_install = srgtsStartUpdate(installedversion)
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load srgtsVersion;
currentversion = v(1);

b_install = 0;

if isequal(currentversion, installedversion)
    str = sprintf('Version %s Release %s is already installed.', ...
        installedversion.Version, ...
        installedversion.Release);
    disp(str);
else
    str = sprintf('Version %s Release %s is installed.\n\n', ...
        installedversion.Version, ...
        installedversion.Release);
    str = sprintf('%sYou can either:\n', str);
    str = sprintf('%s[1] Update to Version %s Release %s.', currentversion.Version, currentversion.Release);
    str = sprintf('%s[2] Cancel installation.\n', str);
    str = sprintf('%sWhat would you like to do?', str);
    b_install = input(str); b_install = b_install == 1;
end

return
