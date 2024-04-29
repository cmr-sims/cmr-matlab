function [net, env] = init_network(env, param)
%INIT_NETWORK   Initialize a network and corresponding environment.
%
%  [net, env] = init_network(env, param)
%
%  PARAM:
%   init_orthogonal_index
%   first_distraction_index
%   subregions
%   has_semantic_structure

% reset the network state, set up associative matrices and subregions
net = create_network(param);

% initialize each context sub-region to a neutral state
% set up indices for the first presented item
env.present_index(logical(param.init_orthogonal_index)) = ...
    param.first_distraction_index(logical(param.init_orthogonal_index));
env.present_index(~param.init_orthogonal_index) = ...
    env.init_index(~param.init_orthogonal_index);

% present an initial item and update context (no learning)
[net, env] = present_distraction(net, env, ... 
				 ones(1, param.subregions), ...
				 ones(1, param.subregions), ...
				 param);

env.present_distraction_index(logical(param.init_orthogonal_index)) = ...
    env.present_distraction_index(logical(param.init_orthogonal_index)) + 1;

env.present_index = ones(1, param.subregions);

% put semantic associations in the network
if any(param.has_semantic_structure)
  [net, env] = create_semantic_structure(net, env, param);
end

