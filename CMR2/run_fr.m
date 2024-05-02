function data = run_fr(param,data)
%
% function data = run_fr(param,data)
% 
% RUN_FR runs a simulation for a free recall (FR) experiment.
% Note that this code is also used for EFR, as in that task we simply
% modify the recall process so that all retrieved items are reported.
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
%   data:           This structure has fields with the experimental lists
%                   and recall sequences to allow for model simulation and
%                   a comparison of the model results to the experimental
%                   data.
%
%
%  OUTPUTS:
%
%
%   data:           The data structure will keep the fields as the file
%                   provided.
%                   Added on will be a .net field with the results from the
%                   model simulation:
%
%                   data.net.recalls has rows indexed by trial, columns
%                   indexed by output position. Elements of this matrix
%                   correspond to serial position, -1 is an intrusion, 0
%                   corresponds to no recall.
%
%                   data.net.rec_itemnos has rows indexed by trial, columns
%                   indexed by output position. Elements of this matrix
%                   correspond to the wordpool number for each recalled
%                   item.
%
%                   data.net.intrusions has rows indexed by trial, columns
%                   indexed by output position. Elements of this matrix
%                   signify the type of intrusion, if any. If no intrusion
%                   was made at a particular trial/output position, the
%                   value is 0. If a prior-list intrusion was made, then 
%                   the element is an integer that corresponds to the 
%                   number of lists back from which the PLI was originally 
%                   presented. This is calculated to facilitate PLI
%                   analyses.
%
%                   data.net.times has rows indexed by trial, columns
%                   indexed by output position. Elements of this matrix
%                   correspond to the cumulative internal time of the model
%                   when the recall was made, in seconds.
%                   
%                   To facilitate analyses, data.net also preserves some of
%                   the structures from data: subject, pres_itemnos, 
%                   list-length, session.

% load in LSA information.
load(param.sem_path);
param.sem_mat{1} = LSA;
clear LSA

% get the unique list of subjects.
[temp,first_rows] = unique(data.subject);
% use this to simulate the subjects in the same order as the behavioral
% data -- unique sorts the subject numbers, and this is usually not
% desirable.
subjlist = data.subject(sort(first_rows));

% set variables.
num_trials = length(data.subject);
trial_count = 1;
nsubj = length(subjlist);

% loop through per subject.
for subject = 1:nsubj
    
  % get session info for this subject. 
  this_subj_session = data.session(data.subject==subjlist(subject));
  
  % loop through sessions per subject.
  for session = (unique(this_subj_session))'
      
      % extract out the rows corresponding to this subject.
      this_session_rows = and(data.subject==subjlist(subject),data.session==session);
      
      % set the items presented to the subject for this session (pres_itemnos)
      param.pres_itemnos = {};
      temp_pres_itemnos = data.pres_itemnos(this_session_rows,:);
      
      % reformat for the model.
      for j = 1:size(temp_pres_itemnos,1)
          param.pres_itemnos{j} = temp_pres_itemnos(j,:);
      end
    
      % run trial
      trial(trial_count) = simulate_fr_abridged(param);
      
      trial_count = trial_count + 1;

  end
  
end

% grab the fields created by simulations, and string together
f = fieldnames(trial(1));
for i = 1:length(f)
  data.net.(f{i}) = [];
end

% stitch the fields together to make a data structure
for trial_num = 1:length(trial)
  for field_name = 1:length(f)
    data.net.(f{field_name}) = [data.net.(f{field_name}); trial(trial_num).(f{field_name})];
  end
end

% grab other useful fields from the original data structure
data.net.subject = data.subject;
data.net.pres_itemnos = data.pres_itemnos;
data.net.session = data.session;
data.net.list_length = data.list_length;

% construct the intrusions field
data.net.intrusions = make_intrusions(data.net.rec_itemnos,data.net.pres_itemnos,data.net.subject);