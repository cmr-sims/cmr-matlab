function [data,net] = simulate_dfr_abridged(param)
%   SIMULATE_DFR_ABRIDGED  Simulates a session of free recall as efficiently as
%                possible assuming:
%                - all items are presented exactly ONCE for the first
%                presented list
%                - no within-list distractors
%                - there must be end of list distraction
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

% create the environment (env) for presenting items, determining
% 'patterns' of presented items under the assumption that
% representations are orthogonal
env = create_orthogonal_patterns(param.n_patterns, ...
    param.pres_indices, ...
    param.not_presented_indices);

[net,env] = init_network_abridged(param,env);

% first trial
% We assume that init_network_abridged was recalled BEFOREHAND, so that all
% of these variables only need to get initialized ONCE.

% end-of-list distraction: maybe incorporate this eventually.
env.present_index(logical(param.dfr_disrupt_regions)) = ...
    env.present_distraction_index(logical(param.dfr_disrupt_regions));
net = present_distraction(net, env, ...
    param.dfr_disrupt_regions, ...
    param.B_dfr, param);
env.present_distraction_index(logical(param.dfr_disrupt_regions)) = ...
    env.present_distraction_index(logical(param.dfr_disrupt_regions)) + 1;

% recall period
[data, net] = param.recall_task_fn(net, env, param);

% aggregate trial_data with data from the rest of the session
% f = fieldnames(trial_data);
% for j = 1:length(f)
%     if ~isfield(data,f{j})
%         data.(f{j}) = trial_data.(f{j});
%     else
%         data.(f{j})(end+1,:) = trial_data.(f{j});
%     end
% end