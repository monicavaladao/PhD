function [] = srgtsUninstall()
%Function srgtsUninstall uninstalls the SURROGATES Toolbox of your machine
%when you type:
%>> srgtsUninstall

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

disp('+----------------------------------------------+');
disp('| SURROGATES Toolbox                           |');
disp('| Working at full speed!!!                     |');
disp('+----------------------------------------------+');

disp(sprintf('\nUninstalling SURROGATES Toolbox...'));

srgtsRootDir = srgtsRoot;
load ./system/srgtsVersion;
toolboxversion = v(1);
[b_isversionok, interpreter, interpreterversion, minimunversion] = srgtsCheckCompatibility(toolboxversion);


[dummy, hostname] = system('hostname');
if strcmp(interpreter, 'OCTAVE')
    hostname = hostname(1:end-2);
else
    hostname = hostname(1:end-1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% changing search path
disp(sprintf('\nRemoving directories from search path...'));
str_directory = sprintf('___directory___%s___%s___.mat', interpreter, hostname);
if ( exist(sprintf('./%s', str_directory),'file') == 2 )
    load(str_directory);
    nfolders = length(directory);
    for c1 = 1 : nfolders
        rmpath(directory{c1});
        disp(sprintf('\t%s', directory{c1}));
    end
    delete(str_directory);
end

disp(sprintf('\nSaving search path...'));
if strcmp(interpreterversion.Name, 'MATLAB') && strcmp(interpreterversion.Version, '6.5')
    updatePath = path2rc;
else
    updatePath = savepath;
end

rehash path;
rehash toolboxreset;
rehash toolboxcache;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% conclunding operations
disp(sprintf('\nDeleting files/folders...'));
if strcmp(interpreter, 'OCTAVE')
    if ispc
        eval(sprintf('system(''rmdir /S /Q "%s/system/%s/%s"'');', srgtsRootDir, interpreter, hostname));
    else
        eval(sprintf('system(''rm -r "%s/system/%s/%s"'');', srgtsRootDir, interpreter, hostname));
    end
else
    delete(sprintf('%s/system/%s/%s/surrogates/svm/*.*', srgtsRootDir, interpreter, hostname));
    delete(sprintf('%s/system/%s/%s/surrogates/gp/*.*', srgtsRootDir, interpreter, hostname));
    eval(sprintf('!rmdir /S /Q "%s/system/%s/%s"', srgtsRootDir, interpreter, hostname));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if updatePath == 0
    disp(sprintf('\nUninstallation is complete.\n\nTo install %s %s Release %s again,\njust go to this directory and type "srgtsInstall"',toolboxversion.Name,toolboxversion.Version,toolboxversion.Release));
else
    str = sprintf('UNINSTALLATION FAILURE!\n');
    disp(sprintf('%sProbably, your user account does not have permission for updating\nthe search path!\n', str));
    disp(sprintf('%sFeel free to send me an email: felipeacviana@gmail.com\n\n', str));
end

return
