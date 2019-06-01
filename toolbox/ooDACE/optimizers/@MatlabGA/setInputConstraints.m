%> @file "@MatlabGA/setInputConstraints.m"
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
%>	this = setInputConstraints( this, con )
%
% ======================================================================
%> Sets input constraints
% ======================================================================
function this = setInputConstraints( this, con )

    import java.util.logging.*
    logger = Logger.getLogger('Matlab.MatlabGA');

    % empty constraints

    % A*x <= b
    this.problem.Aineq=[];
    this.problem.Bineq=[];

    % A*x = b (not supported)
    this.problem.Aeq=[];
    this.problem.Beq=[];

    % 1 function handle
    this.problem.nonlcon=[];
    nonlinear={};

    numNonlinear=0;
    for i=1:length(con)

        switch class(con{i})
            case 'LinearConstraint'
                [Aineq Bineq] = getInternal(con{i});

                % combine with previous constraints
                this.problem.Aineq = [this.problem.Aineq ; Aineq];
                this.problem.Bineq = [this.problem.Bineq ; -Bineq];
            otherwise % nonlinear
                nonlinear{end+1} = con{i};
        end
    end

    if ~isempty( nonlinear )
        this.nonlcon = @(x) vectorEvaluateConstraint( nonlinear, x );
    end
end