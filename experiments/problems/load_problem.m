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
        
    case 'levy'
		problem.fobj = @levy;
		problem.n = n;
		problem.name = 'Levy';
		problem.lb = repmat(-10, 1, problem.n);
		problem.ub = repmat(10, 1, problem.n);  
        
    case 'schwefel'
		problem.fobj = @schwefel;
		problem.n = n;
		problem.name = 'Schwefel';
		problem.lb = repmat(-500, 1, problem.n);
		problem.ub = repmat(500, 1, problem.n);         
		
    case 'perm0db'
		problem.fobj = @perm0db;
		problem.n = n;
		problem.name = 'Perm0db';
		problem.lb = repmat(-n, 1, problem.n);
		problem.ub = repmat(n, 1, problem.n); 
        
    case 'sumsqu'
		problem.fobj = @sumsqu;
		problem.n = n;
		problem.name = 'Sumsqu';
		problem.lb = repmat(-10, 1, problem.n);
		problem.ub = repmat(10, 1, problem.n);  
        
    case 'trid'
		problem.fobj = @trid;
		problem.n = n;
		problem.name = 'Trid';
		problem.lb = repmat(-n^2, 1, problem.n);
		problem.ub = repmat(n^2, 1, problem.n);        
  
    case 'zakharov'
		problem.fobj = @zakharov;
		problem.n = n;
		problem.name = 'Zakharov';
		problem.lb = repmat(-5, 1, problem.n);
		problem.ub = repmat(10, 1, problem.n); 
        
    case 'dixonpr'
		problem.fobj = @dixonpr;
		problem.n = n;
		problem.name = 'Dixonpr';
		problem.lb = repmat(-10, 1, problem.n);
		problem.ub = repmat(10, 1, problem.n);        
     
       
     case 'stybtang'
		problem.fobj = @stybtang;
		problem.n = n;
		problem.name = 'Stybtang';
		problem.lb = repmat(-5, 1, problem.n);
		problem.ub = repmat(5, 1, problem.n);        
        
      case 'rastrigin'
		problem.fobj = @rastrigin;
		problem.n = n;
		problem.name = 'Rastrigin';
		problem.lb = repmat(-5.12, 1, problem.n);
		problem.ub = repmat(5.12, 1, problem.n);       
end

    
end
