function out_str = srgtsSBDODiagnose(actualFN, ndv, srgtsEGOvariant, npoints, ncycles, nppcycle)
%Prints some diagnostic information about the problem

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
aux = srgtsVersion;

out_str = sprintf('%s Version %s - Release %s\n',...
                    aux.Name,...
                    aux.Version,...
                    aux.Release);
                
out_str = [out_str sprintf('\nGENERAL INFORMATION') ];
out_str = [out_str sprintf('\n\tFunction            = %s',func2str(actualFN))];
out_str = [out_str sprintf('\n\tNumber of variables = %d' , ndv ) ];

out_str = [out_str sprintf('\n\nSETUP') ];
out_str = [out_str sprintf('\n\tSBDO/RBDO function       = %s',srgtsEGOvariant)];
out_str = [out_str sprintf('\n\tInitial number of points = %d', npoints ) ];
out_str = [out_str sprintf('\n\tMaximum number of cycles = %d', ncycles ) ];
out_str = [out_str sprintf('\n\tPoints per cycle         = %d', nppcycle ) ];

out_str = [out_str sprintf('\n\nSEQUENTIAL SAMPLING') ];

out_str = [out_str sprintf('\n')];

return

