function [net,env] = reactivate_item_abridged(net, env, param)
%REACTIVATE_ITEM_ABRIDGED   Reactivate a recalled item WITHOUT
%updating weight matrices, i.e. no output encoding.
% also assumes we've specified c_in_norm
%
%  The reactivation of an item during a recall period.
%  Associates f_i with c_{i-1}.
%
%  [net, env] = reactivate_item(net, env, param)
%
%  INPUTS:
%       net
%       env
%     param
%
%  PARAM:
%   subregions
%   custom_context_fn

% ACTIVATE FEATURES % 
net.f = zeros(size(net.f));

for i = 1:length(net.f_sub)
  if env.present_index(i) > 0
    net.f(net.f_sub{i}.idx) = env.patterns{i}(env.present_index(i),:);
  end
end

% UPDATE CONTEXT REPRESENTATION %
net.c_in = net.w_fc * net.f;
% iterate through the sub-areas of context
for i=1:length(net.c_sub)  
  subregion = i;
  net = param.custom_context_fn{i}(net, subregion, param);
end

% NO ASSOCIATION FORMATION!!