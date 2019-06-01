%> @file "startup.m"
%> @authors Ivo Couckuyt
%> @version 1.4 ($Revision$)
%> @date $LastChangedDate$
%> @date Copyright 2010-2013
%>
%> This file is part of the ooDACE toolbox
%> and you can redistribute it and/or modify it under the terms of the
%> GNU Affero General Public License version 3 as published by the
%> Free Software Foundation.  With the additional provision that a commercial
%> license must be purchased if the ooDACE toolbox is used, modified, or extended
%> in a commercial setting. For details see the included LICENSE.txt file.
%> When referring to the ooDACE toolbox please make reference to the corresponding
%> publications:
%>   - Blind Kriging: Implementation and performance analysis
%>     I. Couckuyt, A. Forrester, D. Gorissen, F. De Turck, T. Dhaene,
%>     Advances in Engineering Software,
%>     Vol. 49, pp. 1-13, July 2012.
%>   - Surrogate-based infill optimization applied to electromagnetic problems
%>     I. Couckuyt, F. Declercq, T. Dhaene, H. Rogier, L. Knockaert,
%>     International Journal of RF and Microwave Computer-Aided Engineering (RFMiCAE),
%>     Special Issue on Advances in Design Optimization of Microwave/RF Circuits and Systems,
%>     Vol. 20, No. 5, pp. 492-501, September 2010. 
%>
%> Contact : ivo.couckuyt@ugent.be - http://sumo.intec.ugent.be/?q=ooDACE
%> Signature
%>	 startup()
%
% ======================================================================
%> @brief  Initializes the ooDACE toolbox
%>
%> Setup the toolbox path. Needs to be called once before using the ooDACE toolbox.
% ======================================================================
function startup()

warning off;

if ~license('test', 'optimization_toolbox') 
    disp('The Matlab optimization toolbox seems to be unavailable. The oodacefit.m and demo.m scripts of the ooDACE toolbox use the optimization toolbox to identify the parameters of kriging.');
end

% get location of this file (toolbox root path)
p = mfilename('fullpath');
oodaceRoot = p(1:end-7);

% add matlab class paths
addpath( genpath(oodaceRoot) );

disp('* The ooDACE toolbox path has been setup...');
disp('* To get started see http://sumowiki.intec.ugent.be/index.php/OoDACE:ooDACE_toolbox');

end
