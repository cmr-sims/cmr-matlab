function [net,env] = reactivate_item_abridged(net, env, param)
%REACTIVATE_ITEM_ABRIDGED   Reactivate a recalled item. Assumes no output
%encoding.
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
%              .c
%              .c_sub
%
%  param:
%   .c_in_norm
%   .custom_context_fn
%   .subregions
%
%  env:
%   .present_index
%   .patterns
%   .list_position

% ACTIVATE FEATURES % 
net.f = zeros(size(net.f));

for i = 1:length(net.f_sub)
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
  subregion = i;
  net = param.custom_context_fn{i}(net, subregion, param);
end