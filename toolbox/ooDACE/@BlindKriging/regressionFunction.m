%> @file "@BlindKriging/regressionFunction.m"
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
%>	[regressionFcn expression terms] = regressionFunction( this, options )
%
% ======================================================================
%> Example:
%> [regressionFcn expression terms] = regressionFunction( this, struct('latex', true, 'precision', '%.5g') )
% ======================================================================
function [regressionFcn expression terms] = regressionFunction( this, options )

    %% degrees matrix
    regressionFcn = this.regressionFcn;
    
    %% optional: the expression and individual terms corresponding to the
    %% degrees matrix
    
    if nargout > 1
        %% get options
        defaults = struct('outputIndex', 1, 'latex', false, 'includeCoefficients', true, 'precision', '%.30g' );
        options = mergeStruct( defaults, options );

        if options.latex
            mult = ' \cdot ';
            intTerm{1} = '%sx_{%i}'; % linear
			intTerm{2} = '%sx.^{2}_{%i}'; % quadratic
			intTerm{3} = '%sx.^{3}_{%i}'; % cubic
			intTerm{4} = '%sx.^{4}_{%i}'; % quartic
        else
            if options.includeCoefficients
                mult = '.*';
    
                % xl
                intTerm{1} = sprintf( '%%s(x%%i./%.30g).*sqrt(3./2)', this.levels{1}(end) );
                % xq
                intTerm{2} = sprintf( '%%s(3.*(x%%i./%.30g).^2-2)./sqrt(2)', this.levels{1}(end) );
                
                % xc, xqua: not supported
                intTerm{3} = 'NOT SUPPORTED';
                intTerm{4} = 'NOT SUPPORTED';
                
                %> @note Symbolic expression does not  support maxorder greater than two
                if this.options.regressionMaxOrder > 2
                    warning('Symbolic expression not supported when options.regressionMaxOrder > 2.');
                    warning( 'Regardless whether such terms are actually included in the regression function.');
                    expression = 'Not supported';
                    return;
                end
                
            else
                mult = '';
                
       			intTerm{1} = '%sx%i'; % linear
    			intTerm{2} = '%sx%i^2'; % quadratic
        		intTerm{3} = '%sx%i^3'; % cubic
            	intTerm{4} = '%sx%i^4'; % quartic
			end

        end

        if nargout > 1
            terms = cell( 1,size(this.stats.visitedDegrees,1) );
            terms{1} = 'OK';
        end

        if options.includeCoefficients
            num = sprintf(options.precision,this.alpha(1, options.outputIndex ));
        else
            num = '1'; % or OK
        end
        dim = size(this.getSamples(), 2);
		nrOrders = size(regressionFcn,2) / dim;
        for set=2:size(this.stats.visitedDegrees, 1)

            %% prepend term with coefficients (if wanted)
            if options.includeCoefficients && set <= length(this.idxTerms)

                % coefficient
                coeff = this.alpha(set, options.outputIndex );

                % complex coefficient
                if ~isreal(coeff)
                    coeff = [' +(' num2str(coeff) ')'];
                % real coefficient
                else
                    % positive coefficient
                    if coeff > 0
                        coeff = ['+' sprintf(options.precision,coeff)];
                    % negative coefficient
                    else
                        coeff = ['-' sprintf(options.precision,-coeff)];
                    end
                end
                coeff = [coeff mult];
            else
                coeff = '+';
            end

            %% construct term
            term = [];
            for var=1:dim
				for i=0:nrOrders-1
					if this.stats.visitedDegrees(set,var+i.*dim) > 0
						if ~isempty(term)
                            term = [term mult];
                        end
						term = sprintf( intTerm{i+1}, term, var );
					end
				end
            end

            % add term to expression if it was chosen
            if set <= length(this.idxTerms)
                num = [num coeff term];
            end

            % add term to cell array
            if nargout > 2
                terms{set} = term;
            end

        end

        expression = num;
    end
end
