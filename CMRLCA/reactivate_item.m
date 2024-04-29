function [net,env] = reactivate_item(net, env, param)
%REACTIVATE_ITEM   Reactivate a recalled item.
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
net.c_in = net.w_fc * net.f;
% iterate through the sub-areas of context
for i=1:length(net.c_sub)  
  subregion = i;
  net = param.custom_context_fn{i}(net, subregion, param);
end

% ASSOCIATION FORMATION %

% determine current learning rate
lrate_fc = net.lrate_fc_rec;
lrate_cf = net.lrate_cf_rec;

% weight update
for i=1:length(net.f_sub)
    for j=1:length(net.c_sub)
        net.w_fc(net.c_sub{j}.idx,net.f_sub{i}.idx) = ...
        net.w_fc(net.c_sub{j}.idx,net.f_sub{i}.idx) + ...
        net.c_prev(net.c_sub{j}.idx) * net.f(net.f_sub{i}.idx)' .* lrate_fc(i,j);
    
        net.w_cf(net.f_sub{j}.idx,net.c_sub{i}.idx) = ...
        net.w_cf(net.f_sub{j}.idx,net.c_sub{i}.idx) + ...
        net.f(net.f_sub{j}.idx) * net.c_prev(net.c_sub{i}.idx)' .* lrate_cf(i,j);
    end
end