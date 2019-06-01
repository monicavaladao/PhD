%> @file "generateDatasets.m"
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
%>	 generateDatasets()
%
% ======================================================================
%> @brief  Generates some example datasets used by the demo
% ======================================================================
function generateDatasets()

rng(888);

%% Branin function
data.inDim = 2;
data.LB = [-5 0];
data.UB = [10 15];

transl = (data.UB+data.LB)/2.0;
scale = (data.UB-data.LB)/2.0;
[inFunc outFunc] = calculateTransformationFunctions( [transl; scale] );

%% lhd of 16 samples
lhd = LatinHypercubeDesign(data.inDim, 16);
data.samples = outFunc( lhd.generate() );
data.values = branin(data.samples);

datasetname = fullfile( 'datasets', 'branin_lhd16' );
save(datasetname, 'data', '-v7');

%% lhd of 16 samples + noise
data.values = branin(data.samples) + 200.*(rand(16,1)-0.5);

datasetname = fullfile( 'datasets', 'branin_noise_lhd16' );
save(datasetname, 'data', '-v7');

%% lhd of 16 samples + stochastic kriging
trueValues = branin(data.samples);

% replicate data and add some noise
nrRuns = 4;
noiseValues = repmat(trueValues,1,nrRuns) + 150.*randn(size(data.samples,1),nrRuns);
%noiseValues = repmat(trueValues,1,nrRuns) + 2.*rand(size(data.samples,1),nrRuns);
data.values = [mean(noiseValues,2) var(noiseValues,0,2)]; %./nrRuns];

datasetname = fullfile( 'datasets', 'branin_sk_lhd16' );
save(datasetname, 'data', '-v7');

%% bird
data.inDim = 2;
data.LB = [-4 -4];
data.UB = [4 4];

transl = (data.UB+data.LB)/2.0;
scale = (data.UB-data.LB)/2.0;
[inFunc outFunc] = calculateTransformationFunctions( [transl; scale] );

%% lhd of 16 samples
lhd = LatinHypercubeDesign(data.inDim, 16);
data.samples = outFunc( lhd.generate() );
data.values = birdfcn(data.samples);

datasetname = fullfile( 'datasets', 'bird_lhd16' );
save(datasetname, 'data', '-v7');

%% math_ck multi-fidelity function
data.inDim = 1;
data.LB = 0;
data.UB = 1;

transl = (data.UB+data.LB)/2.0;
scale = (data.UB-data.LB)/2.0;
[inFunc outFunc] = calculateTransformationFunctions( [transl; scale] );

A = 0.5; B = 10; C = -5;
density1 = 20;
density2 = 4;
        
% cheap
fd = FactorialDesign(data.inDim, density1);
samples1 = outFunc( fd.generate() );
values2 = (6.*samples1(:,1) - 2).^2 .* sin(12.*samples1(:,1)-4);
values1 = A.*values2 + B.*(samples1(:,1)-0.5) + C;

% expensive
fd = FactorialDesign(data.inDim, density2);
samples2 = outFunc( fd.generate() );
values2 = (6.*samples2(:,1) - 2).^2 .* sin(12.*samples2(:,1)-4);

data.samples = {samples1; samples2};
data.values = {values1; values2};

datasetname = fullfile( 'datasets', 'math1d_ck_factorial' );
save(datasetname, 'data', '-v7');

end % generateDatasets

function y = branin(x)
    a=1;
    b=5.1/(4*pi*pi);
    c=5/pi;
    d=6;
    h=10;
    ff=1/(8*pi);

    y = a.*(x(:,2)-b.*x(:,1).^2+c.*x(:,1)-d).^2+h.*(1-ff).*cos(x(:,1))+h;
end

function f=birdfcn(x)

    x1 = x(:,1);
    x2 = x(:,2);

    f = exp(cos(x1 - x2)).*sin(((x1 - x2).^2 + x1 + x2)./(1 + (x1 - x2).^2));
end