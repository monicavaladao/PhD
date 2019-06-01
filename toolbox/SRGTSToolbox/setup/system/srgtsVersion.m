function version = srgtsVersion
%Function srgtsVersion displays the current SURROGATES Toolbox version
%information. Thus, for example:
%
%     srgtsVersion: displays the current SURROGATES Toolbox version
%     information.
%
%     VERSION = srgtsVersion: return in VERSION the struct array of version
%     information about the SURROGATES Toolbox. VERSION has the following
%     fields:
%          - Name: toolbox name
%          - Version: toolbox version number
%          - Release: toolbox release string
%          - Date: toolbox release date
%
% Example:
%     % display the version info about the current installation of
%     % the SURROGATES Toolbox.
%     >> srgtsVersion
% 
%     +----------------------------------------------+
%     | SURROGATES Toolbox                           |
%     | Working at full speed!!!                     |
%     +----------------------------------------------+
%     SURROGATES Toolbox  Version X.Y		Release (Z)
% 
% 
%     % return in VERSION the version information about srgtsPRS.
%     >> VERSION = srgtsVersion
% 
%     VERSION = 
% 
%          Name: 'SURROGATES Toolbox'
%       Version: 'X.Y'
%       Release: '(Z)'
%          Date: 'AA-Bbb-20CC'

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
aux = ver;
if strcmp(upper(aux(1).Name), 'OCTAVE')
    aux = 'OCTAVE';
else
    aux = 'MATLAB';
end

load(sprintf('___srgtsVersion___%s___', aux));

switch nargin
    case 0
        aux = v;
    case 1
        aux.Name    = str_toolbox;
        aux.Version = 'Not installed';
        aux.Release = '';
        for counter = 1 : length(v)
            if( strcmp(str_toolbox, v(counter).Name) )
                aux = v(counter);
            end
        end
        
end

switch nargout
    case 0
        disp('+----------------------------------------------+');
        disp('| SURROGATES Toolbox                           |');
        disp('| Working at full speed!!!                     |');
        disp('+----------------------------------------------+');
        disp('');
        for counter = 1 : length(aux)
            str = sprintf('%s %s Version %s\t\tRelease %s',...
                    aux(counter).Name,...
                    char( '.'*ones(1, 18-length(aux(counter).Name)) ),...
                    aux(counter).Version,...
                    aux(counter).Release);
            disp(str);
        end
    case 1
        version = aux;
end

return
