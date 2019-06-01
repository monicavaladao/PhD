%> @file "runBlindKrigingExamples.m"
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
%>	 runBlindKrigingExamples()
%
% ======================================================================
%> @brief Fits blind kriging models to some datasets
% ======================================================================
function runBlindKrigingExamples()

metricName = 'cvpe';

%% Initialize
datafiles = {'engine_head27.txt' [] false; ...
             'piston_slap.txt' [] false; ...
             'borehole027.txt' 'borehole_testset.txt' false; ...
             'borehole200.txt' 'borehole_testset.txt' false; ...
             'truss010.txt' 'truss_testset.txt' true; ...
             'truss140.txt' 'truss_testset.txt' true};

numTests = size(datafiles,1);
for i=1:numTests

    %% Load dataset
    datafile = datafiles{i,1};
    data = load(fullfile('datasets', 'blind', datafile));

    inDim = size(data,2)-1;
    inputIdx = 1:inDim;
    outputIdx = size(data,2);

    samples = data(:,inputIdx);
    values = data(:,outputIdx);

    %% configure blind kriging options
    opts = BlindKriging.getDefaultOptions();
    
    theta0 = zeros(1,inDim);
    opts.hpBounds = [repmat(-2, 1, inDim); repmat(log10(4), 1, inDim)];
    opts.hpOptimizer = SQPLabOptimizer(inDim, 1);

    opts.regressionMetric = metricName;
    opts.retuneParameters = datafiles{i,3};
    opts.regressionMaxOrder = 2;
    opts.regressionMaxLevelInteractions = 2;
	%opts.debug = true;
    
	%% fit blind kriging model
    blindKrige = BlindKriging( opts, theta0, 'regpoly0', @corrgauss);
    [blindKrige ordinaryKrige] = blindKrige.fit( samples, values );
	
	[dummy regrFunc terms] = blindKrige.regressionFunction( struct('latex', false, 'includeCoefficients', false) ); % latex output of regression function
	
	%% score plot
	figure;
    
    if isempty( datafiles{i,2} ) % cross-validation
        stats = blindKrige.getStatistics();
        plot( 1:length(stats.scores),stats.scores,'-k.', 'MarkerSize', 10, 'LineWidth', 1);
        hold on;
        plot( stats.scoreIndex, stats.scoreFinal, 'or' );
        
        title( ['Feature selection process (' datafile ')'], 'interpreter', 'none', 'FontSize', 14);
        ylabel('cvpe', 'FontSize', 14);
        set(gca, 'XTick', 1:length(stats.scores) );
        set(gca,'XTickLabel',terms );
        set(gca,'FontSize',14);
    else % testset
        testset = load(fullfile('datasets', 'blind', datafiles{i,2}));
        testsamples = testset(:,inputIdx);
        testvalues = testset(:,outputIdx);
        
        % calculate AEE
        fprintf(1, 'Average Euclidean Error (AEE) for %s\n', datafile);
        
        ok_predy = ordinaryKrige.predict( testsamples );
        score = averageEuclideanError( ok_predy, testvalues );
        fprintf(1, '- Ordinary Kriging: %g\n', score);
        
        bk_predy = blindKrige.predict( testsamples );
        score = averageEuclideanError( bk_predy, testvalues );
        fprintf(1, '- Blind Kriging: %g\n', score);
        
        %% histograms
        
        % calculate x-axis range
        bk_error = testvalues-bk_predy;
        ok_error = testvalues-ok_predy;
        xmin = min( [bk_error ; ok_error] );
        xmax = max( [bk_error ; ok_error] );
        
        % plot histogram
        subplot(1,2,1);
        hist( bk_error );
        set( gca, 'xlim', [xmin xmax] );
        title(['Distribution of errors on testset (' datafile ')'], 'interpreter', 'none', 'FontSize', 14);
        xlabel('prediction error','FontSize',14,'interpreter','none');
        legend( {'Blind Kriging'}, 'FontSize', 14 );
        set(gca,'FontSize',14);
        
        subplot(1,2,2);
        hist( testvalues-ok_predy );
        set( gca, 'xlim', [xmin xmax] );
        xlabel('prediction error','FontSize',14,'interpreter','none');
        legend( {'Ordinary Kriging'}, 'FontSize', 14 );
        set(gca,'FontSize',14);
    end
    drawnow;

	fprintf( 1, 'Identified regression function (%s):\n %s\n', datafile, regrFunc );
end

end
