function data = run_lbl(param)
%
% function data = run_lbl(param)
%
% RUN_LBL runs a simulation for a list-before-last (LBL) experiment.
%
%
%  INPUTS:
%
%
%   param:          A structure specifying the configuration of the model.
%                   It is assumed that the param structure has a set of
%                   relevant fields; for efficiency no error-checking
%                   ensures that all of the fields are present before the
%                   simulation begins. Refer to README.txt for a list of
%                   relevant fields for this structure.
%
%  OUTPUTS:
%
%
%   data:           The data structure will keep the fields as the file
%                   loaded in, which is specified from the param structure.
%                   Added on will be a .net field with the results from the
%                   model simulation:
%
%                   data.net.recalls_targets has rows indexed by trial,
%                   columns indexed by output position. Elements of this
%                   matrix correspond to serial position, 0 corresponds to
%                   either no recall or a non-target item was recalled at
%                   that output position.
%
%                   data.net.recalls_interv has rows indexed by trial,
%                   columns indexed by output position. Elements of this
%                   matrix correspond to serial position, 0 corresponds to
%                   either no recall or a non-intervening list item was
%                   recalled at that output position.
%
%                   data.net.times has rows indexed by trial, columns
%                   indexed by output position. Elements of this matrix
%                   correspond to the cumulative internal time of the model
%                   when the recall was made, in seconds.
%
%                   To facilitate analyses, data.net also preserves some of
%                   the structures from data: subject, pres_indices,
%                   list-length, task.


% load in LSA information.
load(param.sem_path);
param.sem_mat{1} = LSA;
clear LSA

% load in data.
load(param.data_path);

% set variables.
num_trials = length(data.subject);
subjlist = unique(data.subject);
num_subj = length(subjlist);
param.pres_indices = {};

% loop through per subject. (to date no LBL experiment has been run with 
% more than 1 session per subject, so to keep the code simple we assume 
% each subeject has 1 session.)
for subject = 1:num_subj
    
    % find the trials corresponding to this subject
    these_rows = find(data.subject==subjlist(subject));
    
    % set the item pres_indices and not_presented_indices
    for j = 1:size(these_rows,1)
        
        param.pres_indices{j} = data.pres_itemnos(these_rows(j),1:data.list_length(these_rows(j)));
        
    end
    
    % set list lengths of presented items, as these may vary per subject
    param.list_length = data.list_length(these_rows);
    
    % set end of list distractors based on the subject's task schedule
    param.do_recall = data.task(these_rows);
    param.end_schedule = ones(24,1) * param.B_end_list_recall;
    param.end_schedule(~param.do_recall) = param.B_end_list_norecall;
    
    % determine the appropriate number of dimensions based on the number of
    % words and distractors the subject sees. these numbers could vary
    % depending on the subject's distraction and list-length schedule, so
    % we reset them for each subject.
    [param.n_patterns param.first_distraction_index] ...
        = calculate_session_patterns(param);
    param.n_dimensions = param.n_patterns;
    
    % unlike fr, calculate env here.
    env = create_orthogonal_patterns(param.n_patterns, ...
        param.pres_indices, ...
        param.not_presented_indices);
    env.init_index = zeros(1,param.subregions);
    
    % run trial
    trial(subject) = param.sim_lbl_fcn(param, env);
    
end

% grab the fields created by simulate_fr
f = fieldnames(trial(1));
for i = 1:length(f)
    data.net.(f{i}) = [];
end

% stitch the fields together to make a data structure
for i = 1:length(trial)
    for j = 1:length(f)
        this_field = trial(i).(f{j});
        data.net.(f{j}) = [data.net.(f{j}); this_field];
    end
end

% grab other useful fields from the original data structure
data.net.subject = data.subject;
data.net.pres_itemnos = data.pres_itemnos;
data.net.list_length = data.list_length;
data.net.task = data.task;

% construct a field containing the serial positions of recalled target-list
% items for each trial
data.net.recalls_target = make_recalls_lbl(data.net.rec_itemnos,...
    data.net.pres_itemnos,data.net.subject);

% in LBL, items recalled from the most recent list (stored in data.net.recalls)
% are intervening list items. modify this field to exclude "intrusions"
% from past lists, as we will only want items from the intervening list
% when performing analyses
data.net.recalls_interv = data.net.recalls;
data.net.recalls_interv(data.net.recalls_interv<0) = 0;
data.net.recalls = rmfield(data.net,'recalls');