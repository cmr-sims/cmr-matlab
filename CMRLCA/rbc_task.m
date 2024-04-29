function [data, net, env] = rbc_task(net, env, param)
% RBC_TASK
%
%

if ~isfield(param,'max_outputs')
  max_outputs = -1;
else
  max_outputs = param.max_outputs;
end
% max_outputs = getValFromStruct(param, 'max_outputs', -1);
% num_trials = size(env.pat_indices, 2);

% data structure
data.recalls = zeros(1,max_outputs);
data.rec_itemnos = zeros(1,max_outputs);
data.rec_period = zeros(1,max_outputs);
data.times = zeros(1,max_outputs);

% initialize recall variables
env.timer.time_passed = 0;
env.recall_count = 0;
env.recall_position = 0;

for j = 1:param.subregions
  env.retrieved{j} = zeros(1,size(env.pool_to_item_map{j},1));
  env.thresholds{j} = param.thresh*ones(1,size(env.pool_to_item_map{j},1));
  % set net for recall
  net.c_sub{j}.B = net.c_sub{j}.B_rec;
end
% this gets toggled if there is a post_recall_decision process
report_recall = 1;

% iterate over rbc periods
for j = 1:length(env.rbc_catorder)
  % Proposal - in RBC, these get reset each recall period
  for k = 1:param.subregions
    env.retrieved{k} = zeros(1,size(env.pool_to_item_map{k},1));
    env.thresholds{k} = param.thresh*ones(1,size(env.pool_to_item_map{k},1));
  end

  env.timer.time_passed = 0;
  % present the category cue
  cat_ind = env.pool_to_item_map{2}( ...
      env.pool_to_item_map{2}(:,1)==env.rbc_catorder(j), 2);
  env.present_index = [0 cat_ind];
  net = present_distraction(net, env, [0 1], [0 1], param);
  
  while env.timer.time_passed < env.timer.rec_time
    
    [net, env] = recall_item(net, env, param);

    report_recall = 1;
    
    % TO-DO: env.pat_indices{1} --- hard coded for the single trial case
    if param.post_recall_decision
      % what was the item's category
      if ~isempty(env.recalled_region)
        recalled_cat = ...
            env.pat_indices{1}(2,env.pat_indices{1}(1,:)==env.recalled_index);
        % if this matches the target cat_ind
        if recalled_cat == cat_ind
          report_recall = 1;
        else
          report_recall = 0;
          env.retrieved{env.recalled_region}(1,env.recalled_index) ...
              = 1;
          env.thresholds{env.recalled_region}(1,env.recalled_index) ...
              = 10;
        end
      else
        report_recall = 0;
      end
      
    end
    
    % if timer exactly equals rec_time, it means time is up
    if (env.timer.time_passed < env.timer.rec_time) & (report_recall == 1)
      env.recall_count = env.recall_count + 1;
      % log the event
      data.recalls(1, env.recall_count) = env.recall_position;
      data.rec_period(1, env.recall_count) = j;
      if ~isempty(env.recalled_region)
        data.rec_itemnos(1, env.recall_count) = ...
            env.pool_to_item_map{env.recalled_region}(env.recalled_index,1);
      end
      data.times(1, env.recall_count) = env.timer.time_passed;
      % update the recalled vector
      env.retrieved{env.recalled_region}(env.recalled_index) = 1;
    end
    
    % max output positions break
    if (env.recall_count >= max_outputs) && max_outputs > 0
      break;
    end

  end % while recall

end % for rbc periods



