function [data, net, env] = efr_recall_period(net, env, param)
%EFR_RECALL_PERIOD   Simulate a recall period for an externalized (immediate)
%                    free recall task. Rather than recall only items that
%                    meet the context criterion, now recall all items, but
%                    indicate a "rejection" for items that don't meet the
%                    context criterion.
%
%  [data, net, env] = efr_recall_period(net, env, param)
%
%  for requirements for net, env, param, please see the readme -- too many
%  of the fields for each of these structures are required to be used to
%  all be listed here, and unless the user changes something, these
%  functions should work smoothly with all of the fields given.

% initialize fields for the data structure (see readme for more details)
% recalls:      serial position of each correctly recalled item
% rec_itemnos:  item number in full word pool for each recalled item
% times:        response time (in ms) for each recalled item
% rejected:     was the item was rejected based on the context criterion?
data.recalls = zeros(1, param.max_outputs);
data.rec_itemnos = zeros(1, param.max_outputs);
data.times = zeros(1, param.max_outputs);
data.rejected = zeros(1,param.max_outputs);

% initialize recall variables (names assumed to be self-explanatory)
env.timer.time_passed = 0;
env.recall_count = 0;
env.recall_position = 0;

for j = 1:param.subregions
    % to start, assume no item has been retrieved
    env.retrieved{j} = zeros(1, size(env.pool_to_item_map{j},1));
    % to start, assume all items have threshold = 1
    env.thresholds{j} = param.thresh * ones(1, size(env.pool_to_item_map{j},1));
    % set the context drift rate to beta_{rec}
    net.c_sub{j}.B = net.c_sub{j}.B_rec;
end

% while there's still time left, continue to attempt to recall something
while env.timer.time_passed < env.timer.rec_time

    % keep track of the prior state of context, as we'll need that to
    % compare the just-retrieved item
    c_old = net.c;

    % retrieve an item to potentially be recalled.
    [net, env] = retrieve_item(net, env, param);

    % by default, assume we recall an item and it's not rejected
    report_recall = 1;
    is_reject = NaN;

    % determine the similarity between the retrieved item's input to context
    % and the prior state of context
    if ~isempty(env.recalled_region)
        cdotc_in = dot(net.c_in,c_old);

        % reject this item if it is below the threshold
        if cdotc_in < param.c_thresh
            is_reject = 1;
        end
    else
        % don't recall if nothing was retrieved (e.g., ran out of time)
        report_recall = 0;
    end

    % if timer exactly equals rec_time, it means time is up
    if env.timer.time_passed < env.timer.rec_time
        if report_recall == 1
            env.recall_count = env.recall_count + 1;
            % store the serial position of the recalled item
            data.recalls(1, env.recall_count) = env.recall_position;
            % store the item number of the recalled item
            data.rec_itemnos(1, env.recall_count) = ...
                env.pool_to_item_map{env.recalled_region}(env.recalled_index,1);
            % store the response time associated with this recall
            data.times(1, env.recall_count) = env.timer.time_passed;
            % most important addition: store whether the item was rejected
            data.rejected(1, env.recall_count) = is_reject;

        end

        % determine the thresholds for the next round of recall, given that
        % we just recalled something
        for reg = 1:param.subregions
            for item = 1:size(env.pool_to_item_map{reg})
                if env.thresholds{reg}(item) > param.thresh
                    env.thresholds{reg}(item) = ...
                        param.alpha*(env.thresholds{reg}(item)-param.thresh)+param.thresh;
                end
            end
        end

        % adjust separately the threshold for the just-retrieved item
        env.thresholds{env.recalled_region}(env.recalled_index) = ...
            param.thresh + param.omega;

        % keep track that the item has been retrieved
        env.retrieved{env.recalled_region}(env.recalled_index) = 1;
    end

    % break out of recall if the model reaches the maximum number of output
    % positions (corresponding to the number of serial positions in the list)
    if (env.recall_count >= param.max_outputs) && param.max_outputs > 0
        break;
    end

end % while recall