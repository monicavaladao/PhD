function [] = srgtsSVMGunnFiles(srgtsRootDir, hostname, interpreter)

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

svm_dir = sprintf('../system/%s/%s/surrogates/svm', interpreter, hostname);
disp(sprintf('\nCreating folder: %s\n', svm_dir));
if exist(svm_dir) == 0
    if strcmp(interpreter, 'OCTAVE')
        eval(sprintf('flag = system(''mkdir "%s"'');', svm_dir));
    else
        flag = ~mkdir(svm_dir);
    end
    
    if flag
        str = sprintf('\nFAILURE\n');
        str = sprintf('%sYour user account does not have permission for creating necessary folders.', str);
        disp(str);
        return
    end
else
    disp(sprintf('Folder %s already exists.\n', svm_dir));
end

system_dir = sprintf('%s/system/%s/%s', srgtsRootDir, interpreter, hostname);

str = sprintf('The SURROGATES toolbox uses the SVM toolbox by Gunn (1997).\n');
str = sprintf('%sThe SVM toolbox uses a compiled ("mex") optimizer to fit\n', str);
str = sprintf('%sthe support vector models.\n\n', str);
str = sprintf('%sTo contiue the installation, you need to choose between:\n', str);
str = sprintf('%s[1] copying a pre-compiled file (I have tested it with MATLAB 7.0\n', str);
str = sprintf('%s    and OCTAVE 3.2.4); or\n', str);
str = sprintf('%s[2] compiling the code for your machine (preferable, but may\n', str);
str = sprintf('%s    require you to chose a compiler --- this is the default option).\n', str);
str = sprintf('%sIf you need help, check the documentation.\n\n', str);
str = sprintf('%sWhat would you like to do? ', str);

CopyOrCompile = input(str);
dir_destination = sprintf('%s/surrogates/svm', system_dir);

switch CopyOrCompile
    case 1    % copy compiled version
        if strcmp(interpreter, 'OCTAVE')
            filename = 'svmgunn_qp.mex';
        else
            filename = 'svmgunn_qp.dll';
        end
        file_source      = sprintf('%s/surrogates/svm/svmgunn/mexfiles/compiled/%s', srgtsRootDir, filename);
        file_destination = sprintf('%s/%s', dir_destination, filename);
        copyfile(file_source, file_destination, 'f');
        
    otherwise % compile
        [file_source filename] = srgtsCompileSVMGunn(srgtsRootDir, interpreter);
        file_destination = sprintf('%s/%s', dir_destination, filename);
        movefile(file_source, file_destination, 'f');
end

return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% friend function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [file_source filename] = srgtsCompileSVMGunn(srgtsRootDir, interpreter)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compile extra files:
% Sun Solaris           .mexsol
% HP-UX                 .mexhpux
% Linux on PC           .mexglx
% Linux on AMD Opteron  .mexa64
% Macintosh             .mexmac
% Windows               .mexw32

cd( sprintf('%s/matlabbooster/surrogates/svm/svmgunn/mexfiles', srgtsRootDir) );

if strcmp(interpreter, 'OCTAVE')
    mkoctfile --mex qp.c pr_loqo.c
    delete *.o
else
    mex -O qp.c pr_loqo.c % compile the qp optimizer
end


aux = dir;
set = {'.' '..' 'pr_loqo.c' 'pr_loqo.h' 'qp.c' 'compiled'};
file_source      = [];
filename = '';
for counter = 1 : length(aux)
    value = aux(counter).name;
    if any( strcmpi( value , set)) == 0
        file_source = sprintf('%s/matlabbooster/surrogates/svm/svmgunn/mexfiles/%s', srgtsRootDir, value);
        [pathstr, name, ext, versn] = fileparts(file_source);
        filename = sprintf('svmgunn_qp%s', ext);
    end
end

if isempty(file_source)
    str = sprintf('COMPILATION FAILURE');
    str = sprintf('%sThe most common reason for this failure is\n', str);
    str = sprintf('%slack of C/C++ compiler.\n', str);
    str = sprintf('%sFeel free to send me an email: felipeacviana@gmail.com\n\n', str);
    disp(str);
end

cd( sprintf('%s/setup', srgtsRootDir) );

return
