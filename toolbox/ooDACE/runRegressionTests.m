%> @file "runRegressionTests.m"
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
%>	 runRegressionTests(idx, regressionTestsDir, saveResults)
%
% ======================================================================
%> @brief Runs the regression test suite.
%>
%> @param idx vector indicating the tests to run. Default: 1:5 (optional)
%> @param regressionTestsDir directory of results (optional)
%> @param saveResults saves the results to regressionTestsDir.
%> Default: false (optional)
% ======================================================================
function runRegressionTests(idx, regressionTestsDir, saveResults)

    %> @note Tests should be deterministic, no fixed random state needed
    %> (yet)
    startup; % always run it, otherwise output of first demo call will contain more text (and tests fail)

    nrTests = 5;
    %cmp_func = @cmp_fcmp;
    cmp_func = @cmp_combinedRelative; % compare function for numerical values
    strcmp_func = @strcmp; % compare function for strings
    globalTol = 1.3e-5; % tolerance to accomodate different architectures and Matlab versions
    max_err = -Inf; % debugging: calculates the maximum error that occurs (on numerical values)
                
    if ~exist('idx', 'var' )
        idx = 1:nrTests;
    end
    
    if ~exist('saveResults', 'var' )
        saveResults = false;
    end
    
    if ~exist('regressionTestsDir', 'var' )
        regressionTestsDir = 'regressionTests';
    end

    if saveResults
        mkdir( regressionTestsDir );
        diary( fullfile( regressionTestsDir, 'ver.txt' ) );
        ver;
        diary off;
    end
            
    for i=idx
        % run test
        fprintf('Running test %i...', i);
        try
            [output k_test] = evalc( 'demo(i)' ); % evalc captures text output
        catch e
            fprintf('FAILED.\n')
            disp( e.getReport() );
            continue;
        end
        
        testfileResults = fullfile(regressionTestsDir, sprintf('results_test%i.mat', i));
        testfileKriging = fullfile(regressionTestsDir, sprintf('kriging_test%i.mat', i));
        
        % execute tests
        points = [1.3119 -3.1590; ...
            -1.4493 2.2578; ...
            4.9700 -1.2964; ...
            -2.7583 3.4156; ...
            1.5245 2.3423; ...
            1.0499 0.7103; ...
            -1.1275 -3.2314; ...
            -3.5781 4.5738; ...
            -4.7487 -2.3468; ...
            -0.7889 4.2458];
        
        inDim = size( k_test.getSamples(), 2 );
        
        results = struct();
        %results.output = output; % output of demo script can not be
        % compared

        if isa( k_test, 'CoKriging' )
            results.getSamples = k_test.getSamples();
            results.getValues = k_test.getValues();
            
            results.getSamplesIdx{1} = k_test.getSamplesIdx(1);
            results.getSamplesIdx{2} = k_test.getSamplesIdx(2);
            
            results.getValuesIdx{1} = k_test.getValuesIdx(1);
            results.getValuesIdx{2} = k_test.getValuesIdx(2);
            
            points = [results.getSamples; points(:,1:inDim)];
            
        elseif isa( k_test, 'Kriging' ) % includes Kriging and Blind Kriging
            [results.getSamples{1} results.getSamples{2}] = k_test.getSamples();
            [results.getValues{1} results.getValues{2}] = k_test.getValues();
            
            points = [results.getSamples{1}; points(:,1:inDim)];
        else
            results.getSamples = k_test.getSamples();
            results.getValues = k_test.getValues();
            
            points = [results.getSamples; points(:,1:inDim)];
        end
        
        results.getHyperparameters = k_test.getHyperparameters();
        results.getProcessVariance = k_test.getProcessVariance();
        results.getCorrelationMatrix = k_test.getCorrelationMatrix();
        results.getSigma = k_test.getSigma();
        results.getRegressionMatrix = k_test.getRegressionMatrix();
        results.getRho = k_test.getRho();
        
        results.cvpe = k_test.cvpe();
        results.imse = k_test.imse();
        results.pseudoLikelihood = k_test.pseudoLikelihood();
        results.marginalLikelihood = k_test.marginalLikelihood();
        
        % no expression for co-kriging
        if isa( k_test, 'CoKriging' )
            results.regressionFunction = k_test.regressionFunction(struct());
            results.correlationFunction = k_test.correlationFunction(struct());
        else
            [results.regressionFunction{1} regressionFunction{2}]= k_test.regressionFunction(struct());
            [results.correlationFunction{1} correlationFunction{2}] = k_test.correlationFunction(struct());
            getExpression = k_test.getExpression(1);
            
            %> @note The symbolic expression for the regression, correlation
            %> function and getExpression can not be compared directly
            x1 = points(:,1);
            x2 = points(:,2);
            results.evalExpression = eval(getExpression);
        end
        
        results.points = points;
        [results.predict{1} results.predict{2}] = k_test.predict(points);
        for j=1:size(points,1)
            [results.predict_derivatives{1}(j,:) results.predict_derivatives{2}(j,:)] = k_test.predict_derivatives(points(j,:));
        end
        
        if saveResults
            % save
            % * results [don't compare Kriging model as that may skew the test (behaviour
            % of methods can change without detecting it)]
            % * kriging model (as reference; to find regressions if they occur)
            
            save(testfileResults, 'results' );
            save(testfileKriging, 'k_test' );
            fprintf('SAVED.\n');
        else
            %% validate test results
            results_test = results;
            clear results;
            load(testfileResults);
            
            names = fieldnames(results);
            
            failed = [];
            
            % results are the true values (loaded from disk)
            % results_test are the predicted values
            
            % generic tests
            for j=1:length(names)
                value = results.(names{j});
                
                % use specific tolerance for some tests
                % numerical precision differ between Matlab versions
                if strcmp( names{j}, 'imse' )
                    % a bit looser as it uses monte carlo sampling
                    % especially test 3 is sensitive
                    if i == 3
                        tol = 0.05; % for Matlab 2010a
                    else
                        tol = 1e-2; % for Matlab 2008b
                    end
                else
                    tol = globalTol; % otherwise use global tolerance
                end
                
                try
                    value_test = results_test.(names{j});

                    if ischar( value )
                        if ~strcmp_func( value, value_test )
                           failed = sprintf( '%s %s', failed, names{j} );
                        end
                    elseif iscell( value )
                        for k=1:length(value)
                            if ischar( value{k} )
                                if ~strcmp_func( value{k}, value_test{k} )
                                   failed = sprintf( '%s %s{%i}', failed, names{j}, k );
                                end
                            else
                                % use specific tolerance for some tests
                                % numerical precision differ between Matlab versions
                                if i == 3 && ... % test 3
                                        (strcmp( names{j}, 'predict' ) || strcmp( names{j}, 'predict_derivatives' )) && ...
                                        k == 2 % mse
                                    tol = 0.05; % for Matlab 2010a
                                else
                                    tol = globalTol;
                                end
                                
                                cmp = cmp_func( value{k}, value_test{k} );
                                if cmp > tol
                                   failed = sprintf( '%s %s{%i} <= %e', failed, names{j}, k, cmp );
                                end
                                
                                if ~isempty( cmp )
                                    max_err = max(max_err, cmp);
                                end
                            end
                        end
                    else
                        cmp = cmp_func( value, value_test );
                        if cmp > tol
                           failed = sprintf( '%s %s <= %e', failed, names{j}, cmp );
                        end
                        
                        if ~isempty( cmp )
                            max_err = max(max_err, cmp);
                        end
                    end % test type
                catch e
                    failed = sprintf( '%s %s', failed, names{j} );
                end
            end % for fieldnames
            clear results; % next tests don't use a reference
            
            % specific tests
            
            % testExpression
            if isfield( results_test, 'evalExpression' )
                cmp = cmp_func( results_test.evalExpression, results_test.predict{1} );
               if cmp > tol % tol_expr
                   failed = sprintf( '%s testExpression <= %e', failed, cmp );
               end
            end
            
            % leave-one-out crossvalidation (xval test)
            if ~isa( k_test, 'CoKriging' ) && ~isa( k_test, 'BlindKriging' )
                xvalSamples = k_test.getSamples();
                xvalValues = k_test.getValues();
                xvalN = size( xvalValues, 1);
                xval = zeros( size( xvalValues ) );
                for j=1:xvalN
                    
                   % Stochastic kriging need to change Sigma matrix for xval
                   Sigma = diag(k_test.getSigma());
                   xvalk = k_test.setOption( 'Sigma', [Sigma(1:j-1,:); Sigma(j+1:end,:)] );
                    
                   % fit xval model on existing hyperparameters
                   xvalk = xvalk.fit( [xvalSamples(1:j-1,:); ...
                       xvalSamples(j+1:end,:)], ...
                       [xvalValues(1:j-1,:); ...
                       xvalValues(j+1:end,:)] );

                   xval(j,:) = xvalk.predict( xvalSamples(j,:) );
                end
                xval = sum( ( xval - xvalValues ).^2, 1 ) ./ xvalN;

                cmp = cmp_func( xval, results_test.cvpe );
                if cmp > tol % tol_expr
                    failed = sprintf( '%s xval <= %e', failed, cmp );
                end
            end
            
            % final decision
            if isempty( failed )
                fprintf('OK.\n');
            else
                fprintf('FAILED. (%s )\n', failed);
            end
        end % saveResults
    end % for nrTests
    
    %fprintf( 'Maximum error: %e (global tolerance: %e)\n', max_err, tol );
    
    % close all generated plots
    close all;
end % function

% a is real
% b is predicted
function out = cmp_combinedRelative( a, b )
    out = abs( a - b ) ./ ( 1 + abs(a) );
    
    % take max error and convert sparse to full
    out = full( max( max( out ) ));
end