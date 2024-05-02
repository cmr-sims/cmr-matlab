function net = present_item(net, env, param)
%PRESENT_ITEM   Present an item during study.
%
%  The presentation of an item during a study period, and associate
%  f_i with c_{i-1}.
%
%  net = present_item(net, env, param)
%
%  INPUTS: expects net, param, env to be structures with fields as follows
%          (all of these should be given, but just for completeness we list
%           them here)
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
% we'll associate this previous context state (c_{i-1}) with the current
% feature being activated (f_i)
c_prev = net.c;

% ACTIVATE FEATURES % 
net.f = zeros(size(net.f));

for i=1:length(net.f_sub)
  if env.present_index(i) > 0
    net.f(net.f_sub{i}.idx) = env.patterns{i}(env.present_index(i),:);
  end
end

% UPDATE CONTEXT REPRESENTATION %
% The numerator of Equation A1. For generalization purposes, the rest of
% context updating takes place in param.custom_context_fn, here
% context_update
net.c_in = net.w_fc * net.f;
% update context within each subregion.
for i=1:length(net.c_sub)
  net = param.custom_context_fn{i}(net, i, param);
end

% ASSOCIATION FORMATION %

% calculate primacy gradient (Equation A4)
prime_fact = (param.p_scale * ...
	      exp(-param.p_decay * (env.list_position - 1))) + 1;

% determine current learning rate
lrate_fc = net.lrate_fc_enc;
lrate_cf = (net.lrate_cf_enc .* prime_fact);

% weight update (Equation 2)
for i=1:length(net.f_sub)
    for j=1:length(net.c_sub)
        net.w_fc(net.c_sub{j}.idx,net.f_sub{i}.idx) = ...
        net.w_fc(net.c_sub{j}.idx,net.f_sub{i}.idx) + ...
        c_prev(net.c_sub{j}.idx) * net.f(net.f_sub{i}.idx)' .* lrate_fc(i,j);
    
    
        net.w_cf(net.f_sub{j}.idx,net.c_sub{i}.idx) = ...
        net.w_cf(net.f_sub{j}.idx,net.c_sub{i}.idx) + ...
        net.f(net.f_sub{j}.idx) * c_prev(net.c_sub{i}.idx)' .* lrate_cf(i,j);
    end
end