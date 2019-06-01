function [pool] = update_pool(pop_X, chosen_X, chosen_y, pool, params)
% UPDADE_POOL: Upadate the pool of solutions evaluated on original function.
% Input:
%   pop_X: Current population
%   chosen_X: New solutions
%   chosen_y: Evaluate of each row in chosen_X
%   pool: Current pool of solutions
%   params: Structure containing ooDACE and SRGTSToolbox parameters.
% Output:
%   pool: Updated pool

[N_pool, n] = size(pool.X);
[N_pop, ~] = size(pop_X);

% Distance between pool and pop_X, for each solution in pool
d_pool_pop = zeros(N_pool, 1);
for i = 1:N_pool
    d_pool_pop(i) = min(sqrt(sum((repmat(pool.X(i,:), N_pop, 1) - pop_X) .^ 2, 2)));
end

% Remove repeated solutions from chosen_X
[chosen_X, idx, ~] = unique(chosen_X, 'rows', 'stable');
chosen_y = chosen_y(idx);
[N_chosen, ~] = size(chosen_X);

% Try to insert solutions in chosen_X into pool
has_pool_changed = 0;
for i = 1:N_chosen
    
    % Distance between chosen_X(i,:) and all solutions in pool
    [d, idx] = min(sqrt(sum((repmat(chosen_X(i,:), N_pool, 1) - pool.X) .^ 2, 2)));
    
    if d <= params.tol_ratio
        
        % Keep a copy to undo the replacement, if necessary
        bkp_x = pool.X(idx,:);
        bkp_y = pool.y(idx);
        bkp_age = pool.age(idx);
        
        % Replace the solution in the pool
        pool.X(idx,:) = chosen_X(i,:);
        pool.y(idx) = chosen_y(i);
        pool.age(idx) = max(pool.age) + 1;
        
        % Check the replacement
        if ~is_pool_ok(pool, params.tol_std)
            pool.X(idx,:) = bkp_x;
            pool.y(idx) = bkp_y;
            pool.age(idx) = bkp_age;
        else 
            d_pool_pop(idx) = min(sqrt(sum((repmat(pool.X(idx,:), N_pop, 1) - pop_X) .^ 2, 2)));
            has_pool_changed = 1;
        end
        
    else
        
        if N_pool < params.max_pool_size
            
            % Add the solution into the pool
            idx = N_pool + 1;
            pool.X(idx, :) = chosen_X(i,:);
            pool.y(idx) = chosen_y(i);
            pool.age(idx) = max(pool.age) + 1;
            
            % Check insertion
            if ~is_pool_ok(pool, params.tol_std)
                pool.X(idx,:) = [];
                pool.y(idx) = [];
                pool.age(idx) = [];
            else
                N_pool = N_pool + 1;
                d_pool_pop(idx) = min(sqrt(sum((repmat(pool.X(idx,:), N_pop, 1) - pop_X) .^ 2, 2)));
                has_pool_changed = 1;
            end
            
        else
            
            % Find the solution in the pool that is the farthest from pop_X
            [value, idx] = max(d_pool_pop);
            
            % Find the closest distance from chosen_X(i) to pop_X
            [d, idx_pop] = min(sqrt(sum((repmat(chosen_X(i,:), N_pop, 1) - pop_X) .^ 2, 2)));
            
            if d < value
                
                % Keep a copy to undo the replacement, if necessary
                bkp_x = pool.X(idx,:);
                bkp_y = pool.y(idx);
                bkp_age = pool.age(idx);

                % Replace the solution in the pool
                pool.X(idx,:) = chosen_X(i,:);
                pool.y(idx) = chosen_y(i);
                pool.age(idx) = max(pool.age) + 1;

                % Check the replacement
                if ~is_pool_ok(pool, params.tol_std)
                    pool.X(idx,:) = bkp_x;
                    pool.y(idx) = bkp_y;
                    pool.age(idx) = bkp_age;
                else 
                    d_pool_pop(idx) = d;
                    has_pool_changed = 1;
                end
            end
            
        end
        
    end
end

% Update age status in pool structure
if has_pool_changed
    pool.next_age = max(pool.age) + 1;
end

end


% -------------------------------------------------------------------------
% Auxiliar functions
% -------------------------------------------------------------------------

function status = is_pool_ok(pool, tol_std)
    status = ~(any(std(pool.X) < tol_std) || any(isnan(std(pool.X))) || std(pool.y) < tol_std || isnan(std(pool.y)));
end