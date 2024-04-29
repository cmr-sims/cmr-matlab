function [net, env] = present_distraction(net, env, disrupt_regions, ...
                                          beta, param)
%PRESENT_DISTRACTION   Simulate a distraction item during study.
%
%  [net, env] = present_distraction(net, env, disrupt_regions, beta, param)
%
%  INPUTS:
%              net:  network struct.
%
%              env:  environment struct. env.present_index(i) gives the
%                    item that will be presented for subregion i.
%
%  disrupt_regions:  vector of length subregions; true for subregions
%                    that will be disrupted by the distractor.
%
%             beta:  context integration rate for presentation of the
%                    distractor.
%
%  PARAM:
%   c_in_norm         - logical vector indicating whether to normalize
%                       each subregion of c_in.
%   custom_context_fn - handle to a context update function.

% a flag which triggers normalization of the input to the context layer
if ~isfield(param, 'c_in_norm')
  for i = 1:param.subregions
    param.c_in_norm(i) = 1;
  end
end

% ACTIVATE FEATURES % 
net.f(:) = 0;

for i = 1:length(net.f_sub)
  if disrupt_regions(i) && env.present_index(i) > 0
    net.f(net.f_sub{i}.idx) = env.patterns{i}(env.present_index(i),:);
  end
end

% UPDATE CONTEXT REPRESENTATION %
net.c_in = net.w_fc * net.f;

% iterate through the sub-areas of context
for i = 1:length(disrupt_regions)
  if disrupt_regions(i)
    temp = net.c_sub{i}.B;
    net.c_sub{i}.B = beta(i);
    subregion = i;
    net = param.custom_context_fn{i}(net, subregion, param);
    net.c_sub{i}.B = temp;
  end
end

