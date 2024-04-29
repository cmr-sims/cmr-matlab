function data = run_TFR_CMR2(param,datapath)
tic

% function data = run_TFR_CMR2(param,datapath)
% 
% Simulate the control condition of TFR. This is specific to the taskFR
% data set that includes LTP and Polyn et al. 2009 data. Special code is
% required for this data set because these two studies each have different
% LSA matrices.
%
% INPUTS
% param - a parameters structure specifying the configuration of
% the model.
%
% datapath - path to the matlab structure containing the behavioral
% data from the experiment. the data structure must have the following 
% fields:
%
% pres_indices: each row represents one trial of free recall, with the
% items in the row provided in the order in which they should be presented
% to the model. items are indexed globally with respect to all items in the
% word pool.
% not_presented indices: for each subject, one list of items not presented to the
% model but available for recall. these lists should be given in the same
% order as the order of subjects (e.g. the first subject has the first
% list), which may differ from the order of subjects ordered numerically.
% subject: for each presented trial row, a number indicating the subject to
% which that trial was presented.
% session: for each presented trial row, a number indicating the session.
%
% OUTPUTS
% data -the data structure will have the same fields as the data structure 
% loaded from datapath. added on will be the following fields:
%
% taken directly from the original fields:
% net.pres_indices
% net.subject
%
% generated from the model simulations:
% net.recalls: for each trial, the items recalled by the model,
% indexed according to serial position. items recalled that are not from
% the most recently presented list are indexed as -1. each column is an
% output position.
% net.rec_itemnos: for each trial, the items recalled indexed according to
% their global number with respect to the word pool.
% net.times: for each recalled item, the cumulative time that has passed
% before the item is recalled.
%
% calculated from other fields:
% .net.list_length: the number of items presented on each list. here, this
% number is constant across subjects.
% .net.intrusions: for each trial (row) and output position (column),
% indicates the type of intrusion that was made:
%
%       0: no intrusion
%
%       -1: extra-list intrusion (XLI)
%
%       positive integer: prior-list intrusion (PLI), indicating the number
%       of lists back from which the PLI was recalled

load(datapath);

% extract LSA information.
load(param.sem_path);
param.sem_mat{1} = LSA;
clear LSA

% set random state for leaky accumulator decision process.
rand('state',sum(100*clock));

% get the unique list of subjects, in the same order as behavioral data
subj_and_session = data.subject+1000*data.session;
[temp,first_rows] = unique(subj_and_session);
subjlist = subj_and_session(sort(first_rows));

% set variables.
num_trials = 170; %length(subj_and_session);
list_length = size(data.pres_itemnos,2);
param.max_outputs = list_length;
trial_count = 1;
nsubj = length(subjlist);

% loop through per subject.
for subjno = 1:10
    
      subject = subjlist(subjno);
      
      % extract out the relevant rows.
      this_subj_rows = find(subj_and_session==subject);
      
      % set the items presented to the subject for this session (pres_indices)
      param.pres_indices = {};
      temp_pres_indices = data.pres_itemnos(this_subj_rows,:);
      
      % reformat for the model.
      for j = 1:size(temp_pres_indices,1)
          % set the item pres_indices based on the pres_itemnos field
          param.pres_indices{j}(1,:) = data.pres_itemnos(j,:);
          % set the task pres_indices based on the pres_task field
          param.pres_indices{j}(2,:) = data.pres_task(j,:);
      end

      % each subject additionally has one list of items not presented to the
      % model but available for recall (not_presented_indices)
      param.not_presented_indices{1} = data.not_pres_itemnos(subjno,:);
      param.not_presented_indices{2} = data.not_pres_task(subjno,:);
      
      % create schedules of additional shifts in temporal context:
      % for task shifts and the end of list
      param.shift_schedule = find(diff(data.pres_task(this_subj_rows,:))) * param.B_shift;
      param.end_schedule = ones(length(this_subj_rows),1) * param.B_end_list;
      
      % determine the appropriate number of dimensions
      [param.n_patterns param.first_distraction_index] ...
          = calculate_session_patterns(param);
      
      % create the environment (env) for presenting items, determining
      % 'patterns' of presented items under the assumption that
      % representations are orthogonal
      env = create_orthogonal_patterns(param.n_patterns, ...
          param.pres_indices, ...
          param.not_presented_indices);
      
      % set other relevant parameter now that we've determined the number
      % of patterns
      param.n_dimensions = param.n_patterns;
      
      % In order to match Polyn et al. 2009 CMR simulations, we initialize
      % task context with the task for the first item.
      env.init_index = zeros(1, param.subregions);
      start_task = data.pres_task(this_subj_rows(1), 1);
      env.init_index(1, 2) = ...
      env.pool_to_item_map{2} ...
      (find(env.pool_to_item_map{2}(:,1)==start_task),2);
      % run trial
      trial(trial_count) = simulate_fr(param, env);
      
      trial_count = trial_count + 1;
  
end
keyboard
% grab the useful fields from the original data structure
data.net.subject = data.subject(1:num_trials);
data.net.pres_itemnos = data.pres_itemnos(1:num_trials,:);
data.net.listType = data.listType(1:num_trials);
data.net.pres_task = data.pres_task(1:num_trials,:); 

% grab the fields created by simulate_fr, and string together
f = fieldnames(trial(1));
for i = 1:length(f)
  data.net.(f{i}) = [];
end

% find max number of columns in case the different trials differ
maxcols = 0;
for i = 1:length(trial)
  ncols = size(trial(i).recalls,2);
  maxcols = max(ncols, maxcols);
end

% stitch the fields together to make a data structure
for trial_num = 1:length(trial)
  for field_name = 1:length(f)
    this_field = trial(trial_num).(f{field_name});
    ncols = size(this_field,2);
    if ncols < maxcols
      this_field(:,ncols+1:maxcols) = 0;
    end
    data.net.(f{field_name}) = [data.net.(f{field_name}); this_field];
  end
end

% construct the intrusions field
data.net.intrusions = make_intrusions(data.net.rec_itemnos,...
    data.net.pres_itemnos,data.net.subject);

% set other field
data.net.list_length = list_length;