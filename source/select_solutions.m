function [chosen_X, others_X, chosen_pred] = select_solutions(P, N, n, lb, ub, evolution_control, fpred)
% SELECT_SOLUTIONS: Select solutions to evaluate on original function.
%
% Input: 
%   P: Structure with cadidate solutions.
%   N: Number of solutions to select.
%   n: Number of variables.
%
% Output:
%   chosen_X: N solutions selected from structure P
%   others_X: Structure with the remaining solutions
%   chose_pred: Evaluate on fpred of each row in chosen_X

chosen_X = zeros(N,n);
chosen_pred = zeros(N,1);
others_X = P;

switch evolution_control
        
    % Select solutions based on the metamodel
    case 'metamodel'
        
        % Choose one solution per sub-population
        for i = 1:N
            
            % Evaluate solutions in sub-population i
            aux_y = feval_all(fpred, P(i).solution);
            
            % Find solution with the lowest predicted value
            [pred_min, idx_min] = min(aux_y);
            
            chosen_X(i,:) = P(i).solution(idx_min,:);
            chosen_pred(i,1) = pred_min;
            others_X(i).solution(idx_min,:) = [];
        end
                    
        % Perform local search
        [~,idx] = min(chosen_pred);
        x = chosen_X(idx,:);
        [x_ls, y_ls] = patternsearch(fpred, x, [], [], [], [], lb, ub, psoptimset('Display','off'));
        chosen_X(idx,:) = x_ls;
		chosen_pred(idx,1) = y_ls;
        
    % Randomly select solutions
    otherwise
        for i = 1:N
            
            % Choose a solution from sub-population i
            idx = randi(size(P(i).solution, 1));
            chosen_X(i,:) = P(i).solution(idx,:);
            others_X(i).solution(idx,:) = [];

            % Evaluates the chosen solution on the metamodel
            chosen_pred(i,1) = feval_all(fpred, chosen_X(i,:));
        end
end

end
