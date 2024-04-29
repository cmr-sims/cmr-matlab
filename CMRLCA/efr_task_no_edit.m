function [data, net, env] = efr_task_no_edit(net, env, param)
% EFR_TASK_NO_EDIT
% Similar to EFR task, except no items are edited: all are recalled.
%

if ~isfield(param,'max_outputs')
    param.max_outputs = -1;
end

% data structure
data.recalls = zeros(1,param.max_outputs);
data.rec_itemnos = zeros(1,param.max_outputs);
data.times = zeros(1,param.max_outputs);
% data.rejected = zeros(1,param.max_outputs); ~

% initialize recall variables
env.timer.time_passed = 0;
env.recall_count = 0;
env.recall_position = 0;

% if env.list_num>1 ~
%     % determine criterion for items that win the recall competition. ~
%     param.c_thresh = thresh_lbl_last(net,env); ~
% else ~
%     param.c_thresh = thresh_l_first(net,env); ~
% end ~

for j = 1:param.subregions
    env.retrieved{j} = zeros(1,size(env.pool_to_item_map{j},1));
    env.thresholds{j} = param.thresh*ones(1,size(env.pool_to_item_map{j},1));
    % set net for recall
    net.c_sub{j}.B = net.c_sub{j}.B_rec;
end

% recall period
while env.timer.time_passed < env.timer.rec_time
    
    c_old = net.c;
    
    [net, env] = recall_item(net, env, param);
    
    % by default, assume we recall an item but it's not rejected
    report_recall = 1;
    % is_reject = NaN; ~
    
    % how similar is this item to the current context
    % if ~isempty(env.recalled_region) ~
        % cdotc_in = dot(net.c_in,c_old); ~
        
        % reject this item if it is below the threshold
        % if cdotc_in < param.c_thresh ~
            % is_reject = 1; ~
        % end ~
    % else % if nothing was recalled, don't report it ~
        % report_recall = 0; ~
    % end ~
    
    if isempty(env.recalled_region) % ~
        report_recall = 0; % ~
    end % ~
    
    % if timer exactly equals rec_time, it means time is up
    if env.timer.time_passed < env.timer.rec_time
        if report_recall == 1
            env.recall_count = env.recall_count + 1;
            % log the event
            data.recalls(1, env.recall_count) = env.recall_position;
            data.rec_itemnos(1, env.recall_count) = ...
                    env.pool_to_item_map{env.recalled_region}(env.recalled_index,1);
            data.times(1, env.recall_count) = env.timer.time_passed;
            % most important addition: whether the item was reject
            % data.rejected(1, env.recall_count) = is_reject; ~
            
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
    end
    
    % max output positions break
    if (env.recall_count >= param.max_outputs) && param.max_outputs > 0
        break;
    end
    
end % while recall



