function [data, net, env] = fr_task(net, env, param)
%FR_TASK   Simulate a free recall period.
%
%  [data, net, env] = fr_task(net, env, param)
%
%  PARAM:
%   subregions
%   max_outputs
%   c_thresh
%   thresh
%   alpha
%   can_repeat
%   post_recall_decision

if ~isfield(param, 'max_outputs')
  param.max_outputs = -1;
end

% data structure
data.recalls = zeros(1, param.max_outputs);
data.rec_itemnos = zeros(1, param.max_outputs);
data.times = zeros(1, param.max_outputs);

% initialize recall variables
env.timer.time_passed = 0;
env.recall_count = 0;
env.recall_position = 0;

if param.post_recall_decision && ~isfield(param, 'c_thresh')
  if env.list_num > 1
    % determine criterion for items that win the recall competition.
    param.c_thresh = thresh_lbl_last(net, env);
  else
    param.c_thresh = 0;
  end
end

for j = 1:param.subregions
  env.retrieved{j} = zeros(1, size(env.pool_to_item_map{j},1));
  env.thresholds{j} = param.thresh * ones(1, size(env.pool_to_item_map{j},1));
  % set net for recall
  net.c_sub{j}.B = net.c_sub{j}.B_rec;
end

% recall period
while env.timer.time_passed < env.timer.rec_time
  
  c_old = net.c;
  
  [net, env] = recall_item(net, env, param);
  
  report_recall = 1;
  
  if param.post_recall_decision
    % how similar is this item to the current context
    if ~isempty(env.recalled_region)
      cdotc_in = dot(net.c_in, c_old);
      
      % don't record if this is below the threshold
      if cdotc_in < param.c_thresh
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
      data.recalls(1, env.recall_count) = env.recall_position;
      if ~isempty(env.recalled_region)
        data.rec_itemnos(1, env.recall_count) = ...
            env.pool_to_item_map{env.recalled_region}(env.recalled_index,1);
      end
      data.times(1, env.recall_count) = env.timer.time_passed;
    end
    
    if param.can_repeat
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
    end
    
    % keep track that the item has been retrieved
    env.retrieved{env.recalled_region}(env.recalled_index) = 1;
  end
  
  % max output positions break
  if (env.recall_count >= param.max_outputs) && param.max_outputs > 0
    break
  end
  
end % while recall



