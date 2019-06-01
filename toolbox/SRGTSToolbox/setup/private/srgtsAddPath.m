function [directory updatePath char_slash] = srgtsAddPath(srgtsRootDir, hostname, interpreter, interpreterversion)

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

char_slash = '/';

str_booster  = sprintf('%sbooster', lower(interpreter));

c1 = 1;
directory = cell(1,1);
directory{c1} = sprintf('%s%sdoes',srgtsRootDir, char_slash); c1 = c1 + 1;

if strcmp(interpreter, 'OCTAVE') % OCTAVE
    directory{c1} = sprintf('%s%s%s%sstatistics', srgtsRootDir, char_slash, str_booster, char_slash); c1 = c1 + 1;
else % MATLAB
    if exist('ccdesign', 'file') == 2
        directory{c1} = sprintf('%s%s%s%sdoes', srgtsRootDir, char_slash, str_booster, char_slash); c1 = c1 + 1;
    end
    if exist('newrb', 'file') == 2
        directory{c1} = sprintf('%s%s%s%ssurrogates%srbnn', srgtsRootDir, char_slash, str_booster, char_slash, char_slash); c1 = c1 + 1;
    end
    directory{c1} = sprintf('%s%s%s%ssurrogates%ssvm', srgtsRootDir, char_slash, str_booster, char_slash, char_slash); c1 = c1 + 1;
    directory{c1} = sprintf('%s%s%s%ssurrogates%ssvm%ssvmgunn', srgtsRootDir, char_slash, str_booster, char_slash, char_slash, char_slash); c1 = c1 + 1;
end

directory{c1} = sprintf('%s%ssbdo',srgtsRootDir, char_slash); c1 = c1 + 1;
directory{c1} = sprintf('%s%ssbdo%scriteria',srgtsRootDir, char_slash, char_slash); c1 = c1 + 1;
directory{c1} = sprintf('%s%ssbdo%sutils',srgtsRootDir, char_slash, char_slash); c1 = c1 + 1;

directory{c1} = sprintf('%s%ssurrogates',srgtsRootDir, char_slash); c1 = c1 + 1;
directory{c1} = sprintf('%s%ssurrogates%stools',srgtsRootDir, char_slash, char_slash); c1 = c1 + 1;

directory{c1} = sprintf('%s%ssurrogates%sgp',srgtsRootDir, char_slash, char_slash); c1 = c1 + 1;
directory{c1} = sprintf('%s%ssurrogates%sgp%sgpml',srgtsRootDir, char_slash, char_slash, char_slash); c1 = c1 + 1;

directory{c1} = sprintf('%s%ssurrogates%skrg',srgtsRootDir, char_slash, char_slash); c1 = c1 + 1;
directory{c1} = sprintf('%s%ssurrogates%skrg%sdace',srgtsRootDir, char_slash, char_slash, char_slash); c1 = c1 + 1;

directory{c1} = sprintf('%s%ssurrogates%sprs',srgtsRootDir, char_slash, char_slash); c1 = c1 + 1;

directory{c1} = sprintf('%s%ssurrogates%srbf',srgtsRootDir, char_slash, char_slash); c1 = c1 + 1;
directory{c1} = sprintf('%s%ssurrogates%srbf%srbftlbx',srgtsRootDir, char_slash, char_slash, char_slash); c1 = c1 + 1;

directory{c1} = sprintf('%s%ssurrogates%sshep',srgtsRootDir, char_slash, char_slash); c1 = c1 + 1;
directory{c1} = sprintf('%s%ssurrogates%sshep%svtechshepard',srgtsRootDir, char_slash, char_slash, char_slash); c1 = c1 + 1;

directory{c1} = sprintf('%s%ssurrogates%swas',srgtsRootDir, char_slash, char_slash); c1 = c1 + 1;

directory{c1} = sprintf('%s%ssystem',srgtsRootDir, char_slash); c1 = c1 + 1;
directory{c1} = sprintf('%s%ssystem%s%s%s%s', srgtsRootDir, char_slash, char_slash, interpreter, char_slash, hostname); c1 = c1 + 1;
directory{c1} = sprintf('%s%ssystem%s%s%s%s%ssurrogates%sgp', srgtsRootDir, char_slash, char_slash, interpreter, char_slash, hostname, char_slash, char_slash, char_slash); c1 = c1 + 1;

if strcmp(interpreter, 'MATLAB') % MATLAB
    directory{c1} = sprintf('%s%ssystem%s%s%s%s%ssurrogates%ssvm', srgtsRootDir, char_slash, char_slash, interpreter, char_slash, hostname, char_slash, char_slash, char_slash); c1 = c1 + 1;
end

directory{c1} = sprintf('%s%stools%sconservative',srgtsRootDir, char_slash, char_slash); c1 = c1 + 1;
directory{c1} = sprintf('%s%stools%sgsa',srgtsRootDir, char_slash, char_slash); c1 = c1 + 1;
directory{c1} = sprintf('%s%stools%soptm',srgtsRootDir, char_slash, char_slash); c1 = c1 + 1;

disp(sprintf('\nAdding directories to search path...'));
nfolders = c1 - 1;
for c1 = 1 : nfolders
    addpath(directory{c1},'-end');
    disp(sprintf('\t%s', directory{c1}));
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

return
