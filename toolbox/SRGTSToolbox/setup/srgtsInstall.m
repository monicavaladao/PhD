function [] = srgtsInstall()
%Function srgtsInstall installs the SURROGATES Toolbox in your machine
%when you type:
%>> srgtsInstall
%
%At this moment, the setup routine will help you to install (or update) the
%current version of the SURROGATES Toolbox.
%
%For further information see the current version of the users guide in the
%".../SRGTSToolbox/docs" folder.

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

clc

load ./system/srgtsVersion;
toolboxversion = v(1);

disp('+----------------------------------------------+');
disp('| SURROGATES Toolbox                           |');
disp('| Working at full speed!!!                     |');
disp('+----------------------------------------------+');

disp(sprintf('\nInstalling SURROGATES Toolbox %s', toolboxversion.Version));
disp(sprintf('\nChecking compatibility with your system...'));

% check compatilibility with the interpreter version
[b_isversionok, interpreter, interpreterversion, minimunversion] = srgtsCheckCompatibility(toolboxversion);
[dummy, hostname] = system('hostname');
if strcmp(interpreter, 'OCTAVE')
    hostname = hostname(1:end-2);
else
    hostname = hostname(1:end-1);
end

disp(sprintf('\tHostname\t: %s (%s)', hostname, computer));
disp(sprintf('\tInterpreter\t: %s %s %s', interpreter, interpreterversion.Version, interpreterversion.Release));

if b_isversionok
    disp(sprintf('System is compatible with toolbox.'));
else
    str = sprintf('\nFAILURE\n');
    str = sprintf('%sYour system is NOT compatible with the SURROGATES Toolbox!\n', str);
    str = sprintf('%sSURROGATES Toolbox requires at least %s %s.', str, interpreter, minimunversion);
    disp(str)
end

if b_isversionok
    
    b_install = 1;
    if srgtsIsToolboxInstalled
        installedversion = srgtsVersion;
        b_install = srgtsStartUpdate(installedversion(1));
    end
    
    if b_install
        
        % setup variables
        p = mfilename('fullpath');
        srgtsRootDir = fileparts(p);
        srgtsRootDir = fileparts(srgtsRootDir);
        
        
        % compiling/copying SVM and GP files
        if strcmp(interpreter, 'MATLAB')
            srgtsSVMGunnFiles(srgtsRootDir, hostname, interpreter);
        end
        srgtsGPMLFiles(srgtsRootDir, hostname, interpreter);

        % adding directory to search path
        [directory updatePath char_slash] = srgtsAddPath(srgtsRootDir, hostname, interpreter, interpreterversion);
        
        if updatePath == 0
            str_system_dir = sprintf('%s%ssystem%s%s%s%s', srgtsRootDir, char_slash, char_slash, interpreter, char_slash, hostname);
            disp(sprintf('\nSaving system information...'));
            copyfile('./system/srgtsVersion.mat', ...
                sprintf('%s/___srgtsVersion___%s___.mat', str_system_dir, interpreter));
            copyfile('./system/srgtsVersion.m', ...
                sprintf('%s/srgtsVersion.m', str_system_dir));
            save(sprintf('___directory___%s___%s___.mat', interpreter, hostname), ...
                'directory','-v6');
            
            disp(sprintf('\n%s %s Release %s was successfully installed', toolboxversion.Name,toolboxversion.Version,toolboxversion.Release));
            disp(sprintf('HAVE A LOT OF FUN!!!'));
        else
            str = sprintf('\nFAILURE\n');
            str = sprintf('%sYour user account does not have permission for updating\n', str);
            str = sprintf('%ssearch path!', str);
            str = sprintf('%sFeel free to send me an email: felipeacviana@gmail.com\n\n', str);
            disp(str);
        end
    end
    
end

return
