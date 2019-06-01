%> @file "@BlindKriging/regressionMatrix.m"
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
%>	[F dF] = regressionMatrix(this, points)
%
% ======================================================================
%> Regression matrix (model matrix, Vandermonde matrix, ...) for a set of points
%> Based on this.regressionFcn.
%> Uses coded sample matrix!
% ======================================================================
function [F dF] = regressionMatrix(this, points)

    % Orthogonal polynomial coding
    [n p] = size(points);
    order = max(this.options.regressionMaxOrder);
    features = zeros( n, order*p );
    if nargout > 1
        dFeatures = zeros( n, order*p ); % columns: derivative of variable i
    end
    
    for j=1:p % 1:dimension
        k = this.options.regressionMaxOrder(j) + 1; % number of levels for this variable
        levels = this.levels{j};
        
        avg = mean(levels);
        delta = levels(2,:) - levels(1,:);

        [U dU] = this.polynomialCoding( points(:,j), avg, k, delta );
        features(:,[j:p:end]) = sqrt(k) .* U./ repmat(this.polyScaling(j, :), n, 1 );
        
        if nargout > 1
            % only derive j'th variable
            dFeatures(j,j:p:end) = sqrt(k) .* dU ./ repmat(this.polyScaling(j, :), n, 1 );
            dFeatures([1:j-1 j+1:p],j:p:end) = features(ones(p-1,1),j:p:end);
        end
    end

    % After encoding call base method
    F = this.regressionMatrix@Kriging( features );
    if nargout > 1
        dF = this.regressionMatrix@Kriging( dFeatures );
    end
end
