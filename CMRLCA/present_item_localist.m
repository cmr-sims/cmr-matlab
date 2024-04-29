function net = present_item_localist(net, env, param)
%PRESENT_ITEM_LOCALIST   Present an item during study.
%
%  The presentation of an item during a study period.
%  Associates f_i with c_{i-1}.
%
%  This version assumes that items are orthonormal, that only one unit
%  is activated per subregion at a time, and that the activation of
%  that unit is 1. This is the case for all published versions of
%  CMR. If this assumption is correct, then this function will
%  generally be faster than present_item, especially when there are
%  a large number of items in memory (e.g. when simulating multiple
%  lists without resetting the network).
%
%  net = present_item_localist(net, env, param)
%
%  INPUTS: expects net, param, env to be structures with fields as follows.
%     net:     .f
%              .f_sub
%              .w_fc
%              .w_cf
%              .c
%              .c_sub
%              .lrate_fc_enc
%              .lrate_cf_enc
%
%  param:
%   .c_in_norm
%   .p_scale
%   .p_decay
%   .custom_context_fn
%   .subregions
%
%  env:
%   .present_index
%   .patterns
%   .list_position

% SAVE CURRENT CONTEXT REPRESENTATION %
c_prev = net.c;

% ACTIVATE FEATURES % 
net.f = zeros(size(net.f));

for i = 1:length(net.f_sub)
  if env.present_index(i) > 0
    net.f(net.f_sub{i}.idx) = env.patterns{i}(env.present_index(i),:);
  end
end

% UPDATE CONTEXT REPRESENTATION %
net.c_in = sum(net.w_fc(:,find(net.f)), 2);

% update context within each subregion
for i = 1:length(net.c_sub)
  net = param.custom_context_fn{i}(net, i, param);
end

% ASSOCIATION FORMATION %

% calculate primacy gradient
prime_fact = (param.p_scale * ...
	      exp(-param.p_decay * (env.list_position - 1))) + 1;

% determine current learning rate
lrate_fc = net.lrate_fc_enc;
lrate_cf = (net.lrate_cf_enc .* prime_fact);

% weight update
net = weight_update_localist(net, c_prev, lrate_fc, lrate_cf);

