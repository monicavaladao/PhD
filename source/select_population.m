function [pop_X, pop_y, idx_best] = select_population(pop_X,pop_y,chosen_X,chosen_y)
% SELECT_POPULATION: Select the population to nex iteration
% 
% Input:
%   pop_X: Current population
%   pop_y: Evaluate of each row in pop_X
%   chosen_X: New solutions
%   chosen_y: Evaluate of each row in chosen_X
%
%  Output:
%   pop_X: New population
%   pop_y: Evaluate of each row in pop_X
%   idx_best: Index of the best solution in pop_X

% Update the current population
idx = chosen_y < pop_y;
pop_X(idx,:) = chosen_X(idx,:);
pop_y(idx) = chosen_y(idx);
[~, idx_best] = min(pop_y);

end