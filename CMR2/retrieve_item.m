function [net, env] = retrieve_item(net, env, param)
%RETRIEVE_ITEM   Retrieve an item (to potentially recall).
%
%  [net, env] = retrieve_item(net, env, param)
%
%  net, env, param are structures defined elsewhere. by default, they
%  should have all of the specified fields for this code to work properly,
%  but there are too many to specify here to be helpful.
%
%  Roughly:
%  Input
%  net   - provide the current state of the network (context and
%          feature vectors and their association matrices)
%  env   - provide the current state of the environment
%  param - provide the experiment-specific parameters
%  
%  Output
%  net   - stores new values of network based on the retrieved item
%          as the item's context is reinstated (see line 101)
%  env   - stores information about the retrieved item

% Define starting activation values for each item, based by calculating 
% the input to the feature layer based on the current state of context
f_in = net.w_cf * net.c;

% Next, we'll use env to tell us what patterns are going into the recall
% competition, but first initialize information about the items entering
% the competition.
competing_patterns = []; % which items are competing
region_labels = []; % their corresponding subregions
index_labels = []; % their corresponding item indices
in = []; % this will be our input activations (equivalent to x_0 in Equation A5)
retrieved = []; % keep track of whether each item is retrieved
thresholds = []; % stores the threshold each item muss surpass to be retrieved

for i = 1:length(param.recall_regions)
  if param.recall_regions(i)
      % set each of the vectors defined above based on whether they can be
      % recalled
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

% restrict to the 4*(list-length) top strength items
[temp, in_sorted_indices] = sort(in);
npatterns_total = length(in);

above_thresh = in_sorted_indices((npatterns_total-param.npatterns_competing+1):npatterns_total);

% now that we know who's competing, extract out the relevant values from
% each of the vectors
in = in(above_thresh);
region_labels = region_labels(above_thresh);
index_labels = index_labels(above_thresh);
retrieved = retrieved(above_thresh);
thresholds = thresholds(above_thresh);
in(in < 0) = 0; % activations can't be negative

% given the amount of time we have left, convert this to the number of time
% steps we have left to run the decision process
max_cycles = ceil((env.timer.rec_time - env.timer.time_passed) / param.dt);

% determine all possible noise to the accumulator in advance. this is much
% faster than determining the noise at each time step.
noise = randn(RandStream('mrg32k3a','Seed',sum(100*clock)),length(in), max_cycles);

% run the decision process.
[decision_output, time] = decision_accum(param, in, noise, retrieved', thresholds');

% keep track of how much time has passed
env.timer.time_passed = env.timer.time_passed + time;

% the code needs to know the position of the recalled item in the
% study list, as well as the index of the pattern

% decision_output is an index relative to the structure of
% competing_patterns, so use to find corresponding region and index, and
% then set information in the environment based on this item
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

% reactivate retrieved item by re-presenting it to the model
net = param.reac_item_fn(net, env, param);