function [net, env] = recall_item(net, env, param)
%RECALL_ITEM   Recall an item from the network.
%
%  [net, env] = recall_item(net, env, param)
%
%  PARAM:
%   recall_regions
%   first_distraction_index
%   npatterns_competing
%   L
%   K
%   eta
%   dt
%   dt_tau
%   sq_dt_tau
%   lmat
%   reset
%   can_repeat

% initialize
%rand('state',sum(100*clock));

% input to the feature layer, from context cue
f_in = net.w_cf * net.c;

% need env to tell us what patterns are going into the recall
% competition. 
competing_patterns = [];
region_labels = [];
index_labels = [];
in = [];
retrieved = [];
thresholds = [];

for i = 1:length(param.recall_regions)
  if param.recall_regions(i)
    these_patterns = env.patterns{i} ...
	(1:param.first_distraction_index(i) - 1,:);
    competing_patterns = [competing_patterns; these_patterns];
    region_labels = [region_labels ones(1, size(these_patterns, 1)) * i];
    index_labels = [index_labels 1:param.first_distraction_index(i) - 1];
    retrieved = [retrieved env.retrieved{i}];
    thresholds = [thresholds env.thresholds{i}]; 

    region_support = competing_patterns * f_in(net.f_sub{i}.idx); 
    in = [in; region_support];
  end
end

% restrict to the items with some minimal amount of support
if ~isfield(param, 'npatterns_competing')
  param.npatterns_competing = length(in);
end
[temp, in_sorted_indices] = sort(in);
npatterns_total = length(in);

above_thresh = in_sorted_indices((npatterns_total-param.npatterns_competing+1):npatterns_total);

in = in(above_thresh);
region_labels = region_labels(above_thresh);
index_labels = index_labels(above_thresh);
retrieved = retrieved(above_thresh);
thresholds = thresholds(above_thresh);
in(in < 0) = 0;

% run the accumulators
max_cycles = ceil((env.timer.rec_time - env.timer.time_passed) / param.dt);
% this won't be necessary for all decision functions.
noise = randn(RandStream('mrg32k3a','Seed',sum(100*clock)),length(in), max_cycles);
% decision_output is an index relative to the structure of
% competing_patterns  
%param.lmat = ~eye(length(in)) * param.L;
[decision_output, time] = decision_accum(param, in, noise, ...
                                         retrieved', thresholds');

env.timer.time_passed = env.timer.time_passed + time;

% the code needs to know the position of the recalled item in the
% study list, as well as the index of the pattern

% use decision output to find region and index
this_region = region_labels(decision_output);
this_index = index_labels(decision_output);

if ~isempty(this_index)
  orig_position = find(this_index==env.presented_index{env.list_num}(this_region,:),1,'first');
else
  orig_position = [];
end

if ~isempty(orig_position)
  env.recall_position = orig_position;
else
  env.recall_position = -1;
end

env.recalled_index = this_index;
env.recalled_region = this_region;

env.present_index = zeros(1, param.subregions);
env.present_index(this_region) = this_index;

% reactivate retrieved item
net = param.reac_item_fn(net, env, param);
