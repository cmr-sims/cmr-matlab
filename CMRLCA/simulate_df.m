function [data, net] = simulate_df(param, env)
%   SIMULATE_DF  Simulates a session of directed forgetting experiment.
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

% sanity checks

% do all cells in pres_indices have same size?
% can this version remove reference to pres_indices?
% are all required parameters present?
% are there enough indices in each subregion?

max_outputs = getValFromStruct(param,'max_outputs',-1);

% constants
num_trials = size(env.pat_indices,2);

% data structure
data.recalls = zeros(num_trials,max_outputs);
data.rec_itemnos = zeros(num_trials,max_outputs);
data.times = zeros(num_trials,max_outputs);

% add fields to the environment
env.list_num = 0;
env.n_presented_items = 0;
env.list_index = [];
env.timer.rec_time = param.rec_time;
env.presented_index = cell(size(env.pat_indices));
env.present_distraction_index = param.first_distraction_index;

[net, env] = init_network(env, param);

% run the paradigm
for i = 1:num_trials

  % initialize variables for this list
  env.list_num = env.list_num + 1; 
  env.list_position = 1;
  env.n_presented_items = 0;

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
    net = present_item(net, env, param);
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

  % initialize recall variables
  env.timer.time_passed = 0;
  env.recall_count = 0;
  env.recall_position = 0;
  
  if param.post_recall_decision && env.list_num>1
      % determine criterion for items that win the recall competition.
    param.c_thresh = target_threshold(net,env);
  end
    
  for j = 1:param.subregions
      env.recalled{j} = zeros(1,size(env.pool_to_item_map{j},1));
  end
  
  % recall period
  while env.timer.time_passed < env.timer.rec_time

      c_old = net.c;
      
      [net, env] = recall_item(net, env, param);

      report_recall = 1;

      if param.post_recall_decision && env.list_num>1
          % how similar is this item to the current context
          if ~isempty(env.recalled_region)
              cdotc_in = dot(net.c_in,c_old);

              % if cued to recall the current list, don't record if this 
              % is below the threshold
              if cdotc_in <= param.c_thresh && param.list_to_recall == 2
                  report_recall = 0;
              % if cued to recall the list before last, don't record if this 
              % is above the threshold
              elseif cdotc_in > param.c_thresh && param.list_to_recall == 1
                  report_recall = 0;    
              end
          else
              report_recall = 0;
          end

      end

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
          % regardless, update the recall vector so that the same item
          % can't win the decision competition twice during the same trial.
          env.recalled{env.recalled_region}(env.recalled_index) = 1;
      end

    % max output positions break
    if (env.recall_count >= max_outputs) && max_outputs > 0
      break;
    end
   
  end % while recall

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


  





