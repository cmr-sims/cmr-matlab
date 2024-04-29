function data = run_taskFR(param,datapath)
% data = run_taskFR(param,datapath);
%
% Simulate the Task Free Recall experiment using the CMR model.  
%
% param - a parameters structure specifying the configuration of
% the model.
%
% datapath - path to the matlab structure containing the behavioral
% data from the experiment.
%
% Example:
%
% param = param_cmr_full;
% datapath = 'PolyEtal09_data.mat';
% net_data = run_taskFR(param,datapath); 
%

rand('state',sum(100*clock));
param.max_outputs = 30; 

% load the experimental data
load(datapath);
fprintf('experimental data loaded.\n');

subject = data.full.subject;
pres_itemnos = data.full.pres_itemnos;
pres_task = data.full.pres_task;
list_type = data.full.listType;

% load the semantic structures
for i = 1:param.subregions
  param.sem_mat{i} = [];
  if param.has_semantic_structure(i)
    sfile = load(param.sem_path{i});
    param.sem_mat{i} = sfile.sem_mat;
  end
end

num_trials = length(subject);
list_length = size(pres_itemnos,2);

param.pres_indices = cell(1);
param.pres_indices{1} = zeros(param.subregions, list_length);

% loop through trials
for i = 1:num_trials

  % set the item pres_indices based on the pres_itemnos field 
  param.pres_indices{1}(1,:) = pres_itemnos(i,:);
  % set the task pres_indices based on the pres_task field
  param.pres_indices{1}(2,:) = pres_task(i,:);
  
  % determine the appropriate number of dimensions
  [param.n_patterns param.first_distraction_index] ...
      = calculate_session_patterns(param);
  if param.orthogonal_patterns
    param.n_dimensions = param.n_patterns;
  end

  % create the environment
  env = create_orthogonal_patterns(param.n_patterns, ...
                                   param.pres_indices, ...
				   param.not_presented_indices);
  % In order to match PsychRev CMR simulations, we initialize task
  % context with the task for the first item.  
  env.init_index = zeros(1, param.subregions);
  start_task = pres_task(i, 1);
  start_task_pat_index = ...
      env.pool_to_item_map{2} ...
      (env.pool_to_item_map{2}(:,1)==start_task,2);
  env.init_index(1, 2) = start_task_pat_index;

  % run trials one at a time
  temp_trial = simulate_fr(param, env);
  % copy over details of presentation
  temp_trial.listType = list_type(i);
  temp_trial.pres_itemnos = pres_itemnos(i,:);
  temp_trial.pres_task = pres_task(i,:);

  trial(i) = temp_trial;
  
  if mod(i,50)==1
    fprintf('%d ',i);
  end
  
end

fprintf('\n');

% create output data structure
clear data;

% stitch them together
data.subject = subject;

f = fieldnames(trial(1));
for i = 1:length(f)
  data.(f{i}) = [];
end
data.listLength = list_length;

% find max number of columns
maxcols = 0;
for i = 1:length(trial)
  ncols = size(trial(i).recalls,2);
  maxcols = max(ncols, maxcols);
end

for i = 1:length(trial)
  for j = 1:length(f)
    this_field = trial(i).(f{j});
    ncols = size(this_field,2);
    if ncols < maxcols
      this_field(:,ncols+1:maxcols) = 0;
    end
    data.(f{j}) = [data.(f{j}); this_field];
  end
end



