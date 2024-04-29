function [net,env] = reactivate_item_localist(net, env, param)
%REACTIVATE_ITEM_LOCALIST   Reactivate a recalled item.
%
%  The reactivation of an item during a recall period.
%  Associates f_i with c_{i-1}.
%
%  This version assumes that items are orthonormal, that only one unit
%  is activated per subregion at a time, and that the activation of
%  that unit is 1. This is the case for all published versions of
%  CMR. If this assumption is correct, then this function will
%  generally be faster than reactivate_item, especially when there are
%  a large number of items in memory (e.g. when simulating multiple
%  lists without resetting the network).
%
%  [net, env] = reactivate_item_localist(net, env, param)
%
%  INPUTS:
%       net
%       env
%     param
%
%  PARAM:
%   subregions
%   custom_context_fn

% a flag which triggers normalization of the input to the context
% layer
if ~isfield(param, 'c_in_norm')
  for i = 1:param.subregions
    param.c_in_norm(i) = 1;
  end
end

% SAVE CURRENT CONTEXT REPRESENTATION %
net.c_prev = net.c;

% ACTIVATE FEATURES % 
net.f = zeros(size(net.f));

for i = 1:length(net.f_sub)
  if env.present_index(i) > 0
    net.f(net.f_sub{i}.idx) = env.patterns{i}(env.present_index(i),:);
  end
end

% UPDATE CONTEXT REPRESENTATION %
net.c_in = sum(net.w_fc(:,find(net.f)), 2);

% iterate through the sub-areas of context
for i = 1:length(net.c_sub)  
  subregion = i;
  net = param.custom_context_fn{i}(net, subregion, param);
end

% ASSOCIATION FORMATION %

% determine current learning rate
lrate_fc = net.lrate_fc_rec;
lrate_cf = net.lrate_cf_rec;

% weight update
net = weight_update_localist(net, net.c_prev, lrate_fc, lrate_cf);

