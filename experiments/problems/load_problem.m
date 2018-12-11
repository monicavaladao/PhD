function [problem] = load_problem(name,n)
% LOAD_PROBLEM: load a problem by name and number of variables.
% 
% Input:
%	name: name of the problem
%	n   : number of variables
%
% Output:
%
% Problems available:
% 	elipsoid: Elipsoid Function
%	rosen: Rosen Function
%	ackley: Ackley Function
%	griewank: Griewank Function
%	shifted-rotated-rastrigin: Shifted Rotated Rastrigin

problem = struct();

switch name

	case 'elipsoid'
		problem.fobj = @elipsoid;
		problem.n = n;
		problem.name = 'Elipsoid Function';
		problem.lb = repmat(-5.12, 1, problem.n);
		problem.ub = repmat(5.12, 1, problem.n);
		
	case 'rosen'
		problem.fobj = @rosen;
		problem.n = n;
		problem.name = 'Rosen Function';
		problem.lb = repmat(-2.048, 1, problem.n);
		problem.ub = repmat(2.048, 1, problem.n);
			
	case 'ackley'
		problem.fobj =@ackley;
		problem.n = n;
		problem.name = 'Ackley Function';
		problem.lb = repmat(-32.768, 1, problem.n);
		problem.ub = repmat(32.768, 1, problem.n);
		
	case 'griewank'
		problem.fobj = @griewank;
		problem.n = n;
		problem.name = 'Griewank Function';
		problem.lb = repmat(-600, 1, problem.n);
		problem.ub = repmat(600, 1, problem.n);	
		
	case 'shifted-rotated-rastrigin'
		problem.fobj = @shifted_rotated_rastrigin;
		problem.n = n;
		problem.name = 'Shifted Rotated Rastrigin';
		problem.lb = repmat(-5, 1, problem.n);
		problem.ub = repmat(5, 1, problem.n);	
		
		
end

    
end
