function [net, env] = create_semantic_structure(net, env, param)
%CREATE_SEMANTIC_STRUCTURE   Add semantic relationships to a network.
%
%  Assumes that the patterns are orthonormal localist patterns, and
%  that the items are the first patterns generated when patterns are
%  created (prior to distraction patterns).
%
%  [net, env] = create_semantic_structure(net, env, param)
%
%  PARAM:
%   sem_mat
%   on_diag
%   sem_assoc_mats

for i = 1:param.subregions
    if ~isempty(param.sem_assoc_mats{i})
        % grab the indices of the to-be-presented items
        these_pool_inds = env.pool_to_item_map{i}(:,1);
        sem_mat = param.sem_mat{i}(these_pool_inds, these_pool_inds);
        % check to see if there are any NaNs (words missing from the pool)
        if any(isnan(sem_mat(:)))
            error('semantic matrix contains missing values');
        end
        
        %the particular semantic structure we create depends on the values
        %of param.on_diag and param.sem_assoc_mats
        %first we set a few values we will need in all cases
        n = length(sem_mat);
        diag_ind = (1:n)+(0:n-1)*n;
        sem_mat(diag_ind) = 0;
        irange = net.f_sub{i}.idx(1:n);
        
        if strcmp('cf', param.sem_assoc_mats{i})
            
            if param.on_diag
                % Prepare the LSA values for w_cf by scaling by (1-gamma_cf) and s
                cf_sem_mat = sem_mat * param.eye_cf * param.s;
                               
            else % if on_diag
                
                %if on_diag = 0 we scale only by s
                cf_sem_mat = sem_mat * param.s;
                
            end % if on_diag
            
            % place these sem strengths in the w_cf matrix, irrespective of
            % how we choose to multiply semantics
            net.w_cf(irange,irange) = net.w_cf(irange,irange) + cf_sem_mat;
        end
        
        if strcmp('fc',param.sem_assoc_mats{i})
            
            %For w_fc we scale by (1-gamma_fc) and s_fc
            fc_sem_mat = sem_mat * param.eye_fc * param.s_fc;
            
            %add sem info to w_fc
            net.w_fc(irange,irange) = net.w_fc(irange,irange) + fc_sem_mat;
            
        end
        
    end % if has_sem_struc
end % loop through subregions
