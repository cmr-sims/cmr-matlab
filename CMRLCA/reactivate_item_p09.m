function [net, env] = reactivate_item_p09(net, env, param)
%REACTIVATE_ITEM_P09   Reactivate a recalled item, following Polyn et al. 2009.
%  
%  Updates context according to the method of Polyn et al. (2009), where
%  f_i is associated with c_i
%
%  [net, env] = reactivate_item_p09(net, env, param)

% a flag which triggers normalization of the input to the context
% layer
if ~isfield(param, 'c_in_norm')
  for i = 1:param.subregions
    param.c_in_norm(i) = 1;
  end
end

% ACTIVATE FEATURES % 

net.f = zeros(size(net.f));

for i = 1:length(net.f_sub)
  if env.present_index(i) > 0
    net.f(net.f_sub{i}.idx) = env.patterns{i}(env.present_index(i),:);
  end
end

% UPDATE CONTEXT %
net.c_in = net.w_fc * net.f;
for i = 1:length(net.c_sub)  
  net = param.custom_context_fn{i}(net, i, param);
end

% ASSOCIATION FORMATION %

% determine current learning rate
lrate_fc = net.lrate_fc_rec;
lrate_cf = net.lrate_cf_rec;

for i = 1:length(net.f_sub)
  for j = 1:length(net.c_sub)
    net.w_fc(net.c_sub{j}.idx,net.f_sub{i}.idx) = ...
        net.w_fc(net.c_sub{j}.idx,net.f_sub{i}.idx) + ...
        net.c(net.c_sub{j}.idx) * net.f(net.f_sub{i}.idx)' .* lrate_fc(i,j);
    
    net.w_cf(net.f_sub{j}.idx,net.c_sub{i}.idx) = ...
        net.w_cf(net.f_sub{j}.idx,net.c_sub{i}.idx) + ...
        net.f(net.f_sub{j}.idx) * net.c(net.c_sub{i}.idx)' .* lrate_cf(i,j);
  end
end