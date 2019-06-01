%> @file "@BlindKriging/Rmatrix.m"
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
%>	out = Rmatrix(this, usedIdx)
%
% ======================================================================
%> Obtains R by calculating the Kronecker product.
% ======================================================================
function out = Rmatrix(this, usedIdx)

    [n p] = size(this.getSamples());
    hyperparameters = this.getHyperparameters();
   
    O = max( this.options.regressionMaxOrder );
    I = this.options.regressionMaxLevelInteractions;
    nrTerms = factorial(p) ./ (factorial(I) .* factorial(p-I));
    nrTerms = nrTerms .* O^I + p.*O + 1;
    R = zeros(nrTerms, 1);
	
    %nrInter = prod( this.options.regressionMaxOrder+1 );
	for j=1:p % dim
		% Regression part
		levels = this.levels{j};
		
		k = this.options.regressionMaxOrder(j) + 1;
		m = mean(levels);
		delta = levels(2,:) - levels(1,:);
		
		Uj = sqrt(k) .* this.polynomialCoding( levels, m, k, delta ) ./ repmat(this.polyScaling(j, :), k, 1 );
		Uj = [ones(k,1) Uj];
		
		% Correlation part		
		nSamples = 1:k;
		idx = nSamples(ones(k, 1),:);
		a = tril( idx, -1 ); % idx
		b = triu( idx, 1 )'; % idx
		a = a(a~=0); % remove zero's
		b = b(b~=0); % remove zero's
		dist = levels(a,:) - levels(b,:);
		[dummy dummy dummy rho] = this.correlationFcn( hyperparameters(:,j), dist );

		o = (1:k)';
		idx = find(rho > 0);
		psi_j = sparse([a(idx,:); o], [b(idx,:); o], [rho(idx,:); zeros(k,1)]);
		psi_j = (psi_j + psi_j') + diag( ones(k,1) );
		
		%invUj = inv(Uj);
		%Rj =  invUj * psi_j  * invUj';
		Rj = (Uj' * psi_j * Uj) ./ (k.*k);
        
		% only keep diagonal if R becomes too large
		if 1 %nrInter > this.options.RmatrixThreshold
			Rj = diag(Rj) ./ Rj(1,1); % diagonal, scaling
		else
			Rj = Rj ./ Rj(1,1); % full, scaling
        end
        
        if j > 1
            % R 1:
            R1 = R(usedIdx{j-1},:);

            % R 2:
            R2 = Rj(2:end,:); % except constant 1

            % generate idx'ces
            idx1 = 1:size(R1, 1);
            idx1 = idx1( ones(size(R2, 1),1), : );
            idx1 = idx1.';
            idx1 = idx1(:);

            idx2 = 1:size(R2, 1);
            idx2 = idx2( ones(size(R1, 1), 1), : );
            idx2 = idx2(:);

            count = size(idx1, 1 );
            R(freeIdx:freeIdx+count-1,:) = R1(idx1,:) .* R2(idx2,:);
            freeIdx = freeIdx + count;
        else
            freeIdx = size(Rj,1) + 1;
            R(1:freeIdx-1,:) = Rj;
        end
        
        %R = kron( Rj, R ); %R, Rj );
    end

	if 1 %nrInter > this.options.RmatrixThreshold
		o = 1:length(R);
		out = sparse( o, o, R );
    else
		out = R;
    end
    
    return;

%{
    %> @note working reference implementation
    
    % blind kriging paper
    levels = cell2mat( this.levels.' );
    h21 = (levels(2,:)-levels(1,:));
    h31 = (levels(3,:)-levels(1,:));
	[dummy dummy dummy rho] = this.correlationFcn( this.hyperparameters, [h21 ; h31] );
	
    if this.options.regressionMaxOrder == 2
        rl = (3-3.*rho(2,:))./(3+4.*rho(1,:)+2.*rho(2,:));
        rq = (3-4.*rho(1,:)+rho(2,:))./(3+4.*rho(1,:)+2.*rho(2,:));
		
        rtotal = [rl rq];
	elseif this.options.regressionMaxOrder == 3
        rl = (4+2.*rho(1,:)-15./5.*rho(2,:)-18./5*rho(3,:)) ...
			./(4+6.*rho(1,:)+4.*rho(2,:)+2.*rho(3,:));
        rq = (4-2.*rho(1,:)-4.*rho(2,:)+2.*rho(3,:)) ./ ...
			(4+6.*rho(1,:)+4.*rho(2,:)+2.*rho(3,:));
        rc = (4-6.*rho(1,:)+12./5.*rho(2,:)-2./5.*rho(3,:)) ./ ...
			(4+6.*rho(1,:)+4.*rho(2,:)+2.*rho(3,:));
		
        rtotal = [rl rq rc];
    else
        ezdf=ferse; % error
    end

    RM = buildVandermondeMatrix( rtotal, degrees, cfix( @powerBase, size(degrees,2)) );
	
    o = 1:length(RM);
    out = sparse( o, o, RM );
%}
    
end
