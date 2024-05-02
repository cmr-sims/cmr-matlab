function [data, net] = simulate_lbl_abridged2(param, env)
%   SIMULATE_LBL  Simulates a session of the list before last paradigm
%               in free recall.
%
%  INPUTS:
%     param:  A structure dictating the parameters of the free
%             recall simulation.  simulate_fr expects a number of
%             fields in the param structure.
%
%
%  OUTPUTS:
%      data:  A structure containing a record of the behavior of
%             the network.
%
%      net:  A structure containing the network.
%

% constants
num_trials = size(env.pat_indices,2);

% data structure
data.recalls = zeros(num_trials,param.max_outputs);
data.rec_itemnos = data.recalls;
data.times = data.recalls;

% add fields to the environment
env.list_num = 0;
env.n_presented_items = 0;
env.list_index = [];
env.timer.rec_time = param.rec_time;
env.presented_index = cell(size(env.pat_indices));
env.present_distraction_index = param.first_distraction_index;

% first trial
% Initialize the network as if the first list was presented.
[net, env] = init_network_abridged(param,env);

% there's no recall after the first list, so move on to the second list.

% run the paradigm
for i = 2:num_trials
    
    % post-recall distractor
    if param.do_end_list
        env.present_index(logical(param.end_disrupt_regions)) = ...
            env.present_distraction_index(logical(param.end_disrupt_regions));
        net = present_distraction(net, env, ...
            param.end_disrupt_regions, ...
            param.end_schedule(i-1), param);
        % ^ If the above line were at the end of each presented list, we'd
        % use end_schedule(i).
        env.present_distraction_index(logical(param.end_disrupt_regions)) = ...
            env.present_distraction_index(logical(param.end_disrupt_regions)) + 1;
    end
    
    % initialize variables for this list
    env.list_num = env.list_num + 1;
    env.list_position = 1;
    env.list_index = [];
    env.n_presented_items = 0;
    % set net for study
  for j = 1:param.subregions
    net.c_sub{j}.B = net.c_sub{j}.B_enc;
  end
    
    % study period
    for j = 1:size(env.pat_indices{1,i},2)
        
        % present the item
        % set environment indices for network subregions
        env.present_index = env.pat_indices{:,i}(j);
        net = param.pres_item_fn(net, env, param);
        %env.list_index(:, env.list_position) = squeeze(env.pat_indices(i,j,:));
        env.list_position = env.list_position + 1;
        env.n_presented_items = env.n_presented_items + 1;
        env.presented_index{:,env.list_num}(env.n_presented_items) = ...
            env.pat_indices{:,i}(j);
    end % j list_length
    
    if param.do_recall(i)
        
        % determine the thresholds to be used in post-recall retrieval checks.
        % these thresholds will only vary by intervening list length.
        % c_thresh_lbl is the last item of the lbl list, to be used before we
        % get to the target list.
        c_thresh_lbl = param.thresh_lbl_last; %thresh_lbl_last(net,env);
        %       fprintf('c_thresh: %1.4f, rec: %i; ',c_thresh_lbl,param.do_recall(i-1))
        %       fprintf('tll: %i; ',size(pat_indices{1,i-1},2))
        %       fprintf('ill: %i \n',size(pat_indices{1,i},2))
        
        %c_thesh_lblbl is the list before the last before that. use the last
        %item from this list once we're in the target list. for the first
        %target list recalled, we have no lower bound, as with fr.
        if env.list_num>2
            c_thresh_lblbl = param.thresh_lblbl_last; %thresh_lblbl_last(net,env);
        else
            c_thresh_lblbl = 0;
        end
        
        % set parameters such that we assume we begin recall with the
        % intervening list. these parameters are modified when the first
        % item is recalled, i.e. passes the post-decision criterion.
        param.in_target_list = 0;
        for s=1:param.subregions
            net.c_sub{s}.B = param.B_rec;
        end
        
        % initialize recall variables
        env.timer.time_passed = 0;
        env.recall_count = 0;
        env.recall_position = 0;
        for j = 1:param.subregions
            env.retrieved{j} = zeros(1,size(env.pool_to_item_map{j},1));
            env.thresholds{j} = param.thresh*ones(1,size(env.pool_to_item_map{j},1));
        end
        
        % recall period
        while env.timer.time_passed < env.timer.rec_time
            
            c_old = net.c;
            
            [net, env] = retrieve_item(net, env, param);
            
            report_recall = 1;
            
            if param.post_recall_decision
                % how similar is this item to the current context
                if ~isempty(env.recalled_region)
                    cdotc_in = dot(net.c_in,c_old);
                    
                    if param.in_target_list
                        % if we're in the target list, record only if this is
                        % above the threshold
                        
                        if cdotc_in <= c_thresh_lblbl
                            report_recall = 0;
                        end
                        
                    else
                        % if not in the target list yet, record only if this
                        % is below the threshold
                        if cdotc_in <= c_thresh_lbl && cdotc_in > c_thresh_lblbl
                            % now we're in the target list, so adjust parameters
                            % accordingly.
                            param.in_target_list = 1;
                             %reset target list lower threshold
                             if env.list_num>2
                                 c_thresh_lblbl = thresh_lblbl_last(net,env);
                             else
                                 c_thresh_lblbl = 0;
                             end
                            % reset context drift rate
                            
                        else % this isn't a target list item, so don't recall
                            report_recall = 0;
                        end
                    end
                else % didn't recall anything
                    report_recall = 0;
                end
                
            end
            
            %           if ~isempty(env.recalled_index)
            %           sprintf('list:%i; report:%i;',i,report_recall)
            %           if env.recall_position > 0
            %               sprintf('ILI: %i \n',env.recall_position)
            %           elseif ~isempty(find(env.pool_to_item_map{env.recalled_region}(env.recalled_index,1)==env.pat_indices{:,i-1}(:),1))
            %               sprintf('TLI: %i \n',find(env.pool_to_item_map{env.recalled_region}(env.recalled_index,1)==env.pat_indices{:,i-1}(:)))
            %           else
            %               sprintf('intrusion')
            %           end
            %           pause
            %           end
            
            % if timer exactly equals rec_time, it means time is up
            
            if env.timer.time_passed < env.timer.rec_time
                if report_recall == 1
                    env.recall_count = env.recall_count + 1;
                    % log the event
                    data.recalls(i, env.recall_count) = env.recall_position;
                    if ~isempty(env.recalled_region)
                        data.rec_itemnos(i, env.recall_count) = ...
                            env.pool_to_item_map{env.recalled_region}(env.recalled_index,1);
                    end
                    data.times(i, env.recall_count) = env.timer.time_passed;
                    
                end
                % determine the thresholds for items entering the decision
                % competition
                % all previously retrieved items
                for reg = 1:param.subregions
                    for item = 1:size(env.pool_to_item_map{j})
                        if env.thresholds{reg}(item) > param.thresh
                            env.thresholds{reg}(item) = ...
                                param.alpha*(env.thresholds{reg}(item)-param.thresh)+param.thresh;
                        end
                    end
                end
                % just-retrieved item
                env.thresholds{env.recalled_region}(env.recalled_index) = ...
                    param.thresh + param.omega;
                
                % keep track that the item has been retrieved
                env.retrieved{env.recalled_region}(env.recalled_index) = 1;
                
                % keep track if anything has been attempted to be recalled.
                % n_attempts = n_attempts + 1;
            end
            
            
            % max output positions break
            if env.recall_count >= param.max_outputs
                break;
            end
            
            
        end % while recall
    end
    
end % i num_trials

% if after an entire session, no attempts to recall have been made, no need
% to continue with more subjects...this is a bad parameter set. break to go
% back to the next set of parameters.

if sum(sum(data.rec_itemnos)) == 0
    data.bad_params = 1;
else
    data.bad_params = 0;
end

end
