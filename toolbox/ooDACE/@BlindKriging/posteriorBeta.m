%> @file "@BlindKriging/posteriorBeta.m"
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
%>	beta = posteriorBeta(this, R, U)
%
% ======================================================================
%> The coefficient beta are considered a stochastic process
%> with process mean 0 and
%> process variance tau2*R
%> Hence, the posterior is
%> mean = R*U'*inv(psi)
%> variance = tau2*R - tau4/sigma2*R*U'*inv(psiD)*U*
% ======================================================================
function beta = posteriorBeta(this, R, U)

    [dummy scaledValues] = this.getValues(); % NOTE: we need scaled values
    Yt = this.C \ scaledValues;
	
	%psi = full(this.C*this.C');
	%old = inv(psi)*residual
    
    % forward and back substitution
    % inv(CC') * residual
    % inv(C')*inv(C)*residual
    % inv(C')* (C \ residual)
    % C' \ (C \ residual)
    % Ct = this.C \ residual; % (1)
	Ct = Yt - this.Ft*this.alpha; % (2)
    fast_acc = this.C' \ Ct;
    
    beta = R*U'*fast_acc;
    beta = abs(beta);
    
    % variance on beta
    %{
    if 1
        % return standardized coefficient
        % tau2*R - tau4/sigma2*R*U'*inv(psiD)*U*
        
        % aprox.
        %sigma2 = R - R* U' * inv( this.C * this.C' ) * U * R;
        
        %beta = beta ./ abs( diag( sigma2 ) );
    
    end
    %}
end
