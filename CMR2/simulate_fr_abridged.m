function [data,net] = simulate_fr_abridged(param)
%   SIMULATE_FR_ABRIDGED  Simulates a session of free recall as efficiently as
%                possible assuming:
%                - all items are presented exactly ONCE for the first
%                presented list
%                - no within-list distractors
%
%  INPUTS:
%     param:  A structure dictating the parameters of the free
%             recall simulation.  simulate_fr expects a number of
%             fields in the param structure. see readme for details.
%
%
%  OUTPUTS:
%      data:  A structure containing a record of the behavior of
%             the network, including recalled and retrieved items.
%
%      net:  A structure containing the network.

data = struct();

% create the environment (env) for presenting items, determining
% 'patterns' of presented items under the assumption that
% representations are orthogonal
env = create_orthogonal_patterns(param.n_patterns, ...
    param.pres_itemnos, ...
    param.not_presented_indices);

% initialize network and environment, assuming that the first list is a set
% of once-presented items without distractors.
[net,env] = init_network_abridged(param,env);

% recall period
[trial_data, net, env] = param.recall_task_fn(net, env, param);

% aggregate trial_data with data from the rest of the session
f = fieldnames(trial_data);
for j = 1:length(f)
    data.(f{j}) = trial_data.(f{j});
end

% constants
num_trials = size(env.pat_indices,2);

% run the paradigm
for i = 2:num_trials
    
    % post-recall distractor from the previous list -- this way, we don't
    % call on it unnecessarily at the last list, and we don't have these
    % lines of code both outside and within the for loop
    if param.do_end_list
        env.present_index(logical(param.end_disrupt_regions)) = ...
            env.present_distraction_index(logical(param.end_disrupt_regions));
        net = present_distraction(net, env, ...
            param.end_disrupt_regions, ...
            param.end_schedule(i-1), param);
        env.present_distraction_index(logical(param.end_disrupt_regions)) = ...
            env.present_distraction_index(logical(param.end_disrupt_regions)) + 1;
    end
    
    % initialize variables for this list
    env.list_num = env.list_num + 1;
    env.list_position = 1;
    env.n_presented_items = 0;
    % set net for study
    for j = 1:param.subregions
        net.c_sub{j}.B = net.c_sub{j}.B_enc;
    end
    
    % study period
    for j = 1:size(env.pat_indices{i},2)
        
        % present the item
        % set environment indices for network subregions
        env.present_index = env.pat_indices{i}(:,j);
        net = param.pres_item_fn(net, env, param);
        env.list_position = env.list_position + 1;
        env.n_presented_items = env.n_presented_items + 1;
        env.presented_index{env.list_num}(:,env.n_presented_items) = ...
            env.pat_indices{i}(:,j);
        
    end % j list_length
    
    % recall period
    [trial_data, net, env] = param.recall_task_fn(net, env, param);
    % aggregate trial_data with data from the rest of the session

    for j = 1:length(f)
        data.(f{j})(end+1,:) = trial_data.(f{j});
    end
    
end % i num_trials