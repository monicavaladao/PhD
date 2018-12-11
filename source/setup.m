% Configure the MATLAB path to include all folders 
% used by this toolbox.

base_path = getfield(what(), 'path');

addpath(strcat(base_path, '/utils'));
addpath(base_path);
savepath

clear base_path;