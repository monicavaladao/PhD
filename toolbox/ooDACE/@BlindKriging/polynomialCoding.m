%> @file "@BlindKriging/polynomialCoding.m"
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
%>	[U dU] = polynomialCoding( this, samples, m, k, delta )
%
% ======================================================================
%>	Encodes the sample matrix using polynomial contrasts
%>	See book of Hamada
%>	- http://www.stat.ncsu.edu/people/dickey/st512/lab09/OrthPoly.html
%>	
% ======================================================================
function [U dU] = polynomialCoding( this, samples, m, k, delta )


n = size(samples,1);
U = zeros(n, k-1 );
dU = zeros(n, k-1 );
if k > 1
	U(:,1) = (samples - m)./ delta;
	dU(:,1) = (1-m) ./ delta;

	if k > 2
		U(:,2) = U(:,1).^2 - (k.^2 - 1) ./ 12;
		dU(:,2) = 2.*U(:,1).*dU(:,1) - (k.^2 - 1) ./ 12;

		if k > 3
			U(:,3) = U(:,1).^3 - U(:,1).*((3.*k.^2-7) ./ 20);
			dU(:,3) = 3.*U(:,1).^2.*dU(:,1) - dU(:,1).*((3.*k.^2-7) ./ 20);

			if k > 4
				U(:,4) = U(:,1).^4 - U(:,1).^2.*((3.*k.^2-13) ./ 14) + (3.*(k.^2-1).*(k.^2-9)) ./ 560;
				dU(:,4) = 4.*U(:,1).^3.*dU(:,1) - 2.*U(:,1).*dU(:,1).*((3.*k.^2-13) ./ 14) + (3.*(k.^2-1).*(k.^2-9)) ./ 560;
			end
		end
	end
end	

end
