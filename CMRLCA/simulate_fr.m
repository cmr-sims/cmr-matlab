function [data, net] = simulate_fr(param, env)
%SIMULATE_FR   Simulate a session of free recall.
%
%  [data, net] = simulate_fr(param, env)
%
%  INPUTS:
%    param:  A structure dictating the parameters of the free recall
%            simulation.  simulate_fr expects a number of fields in the
%            param structure.
%
%  OUTPUTS:
%     data:  A structure containing a record of the behavior of the
%            network.
%
%      net:  A structure containing the network.

% constants
num_trials = size(env.pat_indices, 2);

data = struct();

% add fields to the environment
env.list_num = 0;
env.n_presented_items = 0;
env.list_index = [];
env.timer.rec_time = param.rec_time;
env.presented_index = cell(size(env.pat_indices));
env.present_distraction_index = param.first_distraction_index;

% create a new network, with context and feature layers initialized
[net, env] = init_network(env, param);

% run the paradigm
if param.save_context
  % currently, just saving context after presentation of each item
  net.c_study = NaN(num_trials, size(env.pat_indices{1}, 2), length(net.c));
  net.c_study_in = NaN(num_trials, size(env.pat_indices{1}, 2), length(net.c));
end
for i = 1:num_trials
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
    
    % continuous distraction
    if param.do_cdfr 
      env.present_index(logical(param.cdfr_disrupt_regions)) = ...
	  env.present_distraction_index(logical(param.cdfr_disrupt_regions));
      net = present_distraction(net, env, ...
				param.cdfr_disrupt_regions, ...
				param.cdfr_schedule(i,j), ...
				param);
      env.present_distraction_index(logical(param.cdfr_disrupt_regions)) = ...
	  env.present_distraction_index(logical(param.cdfr_disrupt_regions)) + 1;
    end
    
    % shift-related disruption
    if param.do_shift && j > 1
      % test for shift on critical regions
      for k = 1:length(param.shift_trigger_regions)
	if param.shift_trigger_regions(k) && ...
              (env.pat_indices{i}(k,j) ~= env.pat_indices{i}(k,j-1))
	  env.present_index(logical(param.shift_disrupt_regions)) = ...
	      env.present_distraction_index(logical(param.shift_disrupt_regions));
	  net = present_distraction(net, env, ...
				    param.shift_disrupt_regions, ...
				    param.shift_schedule, param);
	  env.present_distraction_index(logical(param.shift_disrupt_regions)) = ...
	      env.present_distraction_index(logical(param.shift_disrupt_regions)) + 1;
	end
      end
    end
    
    % present the item
    % set environment indices for network subregions
    env.present_index = env.pat_indices{i}(:,j);
    net = param.pres_item_fn(net, env, param);
    if param.save_context
      net.c_study(i,j,:) = net.c;
      net.c_study_in(i,j,:) = net.c_in;
    end
    
    env.list_position = env.list_position + 1;
    env.n_presented_items = env.n_presented_items + 1;
    env.presented_index{env.list_num}(:,env.n_presented_items) = ...
        env.pat_indices{i}(:,j);
    
  end % j list_length

  % end-of-list distraction
  if param.do_dfr
    env.present_index(logical(param.dfr_disrupt_regions)) = ...
        env.present_distraction_index(logical(param.dfr_disrupt_regions));
    net = present_distraction(net, env, ...
                              param.dfr_disrupt_regions, ...
                              param.dfr_schedule(i), param);
    env.present_distraction_index(logical(param.dfr_disrupt_regions)) = ...
        env.present_distraction_index(logical(param.dfr_disrupt_regions)) + 1;
  end
  
  % recall period
  [trial_data, net, env] = param.recall_task_fn(net, env, param);
  % aggregate trial_data with data from the rest of the session
  f = fieldnames(trial_data);
  for j = 1:length(f)
    if ~isfield(data,f{j})
      data.(f{j}) = trial_data.(f{j});
    else
      data.(f{j})(end+1,:) = trial_data.(f{j});
    end
  end
  
  % post-recall distractor
  if param.do_end_list && i ~= num_trials
    env.present_index(logical(param.end_disrupt_regions)) = ...
	env.present_distraction_index(logical(param.end_disrupt_regions));
    net = present_distraction(net, env, ...
			      param.end_disrupt_regions, ...
			      param.end_schedule(i), param);
    env.present_distraction_index(logical(param.end_disrupt_regions)) = ...
	env.present_distraction_index(logical(param.end_disrupt_regions)) + 1;
  end
  
end % i num_trials