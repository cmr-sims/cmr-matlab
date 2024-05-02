function [net, env] = present_distraction(net, env, disrupt_regions, ...
                                          beta, param)
%PRESENT_DISTRACTION   Simulate a distraction item during study (and no
%                      association of this item to context).
%
%  [net, env] = present_distraction(net, env, disrupt_regions, beta, param)
%
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

% ACTIVATE FEATURES % 
net.f = zeros(size(net.f));

for i = 1:length(net.f_sub)
  if disrupt_regions(i) && env.present_index(i) > 0
    net.f(net.f_sub{i}.idx) = env.patterns{i}(env.present_index(i),:);
  end
end

% UPDATE CONTEXT REPRESENTATION %
% The numerator of Equation A1. For generalization purposes, the rest of
% context updating takes place in param.custom_context_fn, here
% context_update
net.c_in = net.w_fc * net.f;

% update context within each subregion.
for i = 1:length(disrupt_regions)
  if disrupt_regions(i)
    temp = net.c_sub{i}.B;
    net.c_sub{i}.B = beta(i);
    subregion = i;
    net = param.custom_context_fn{i}(net, subregion, param);
    net.c_sub{i}.B = temp;
  end
end

