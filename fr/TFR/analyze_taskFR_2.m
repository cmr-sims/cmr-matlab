function res = analyze_taskFR_2(data, sem_mat)
% res = analyze_taskFR_2(data, sem_mat)
% ANALYZE_TASKFR_2
% Various analyses for the TaskFR paradigm
%
% INPUTS:
%       data: behavioral data from the experiment or the model
%
%    sem_mat: LSA matrix containing the similarity scores between
%             all studied items
%
% OUTPUTS:
%        res: structure containing the result of the analyses
%
% DEPENDENCY:
%    Behavioral Toolbox (Release 1)
%    http://memory.psych.upenn.edu/behavioral_toolbox
%
% USAGE:
%    To run the analyses on the PolyEtal09 data, pass in the 'full'
%    substructure of the data structure rather than the whole data
%    structure, like below:
%    res = analyze_taskFR_2(data.full, sem_mat);
%
%    To run the analyses on the CMR results, pass the data
%    structure ouput by the model, like below:
%    res = analyze_taskFR_2(data, sem_mat);

% sanity checks
if ~exist('data','var')
  error('You must pass a data structure.')
elseif ~exist('sem_mat','var')
  error('You must pass a similarity matrix.')
end

% initialize results structure
res = struct();
% initialize figure number
fignum = 1;

% paradigm and experiment information
listLength = 24;
subjs = unique(data.subject);
nsubj = length(subjs);

% remove extra zeros from end of presentation data
data.pres_itemnos = data.pres_itemnos(:,1:listLength);
data.pres_task = data.pres_task(:,1:listLength);

% subsets of the data structure based on list type
listType = data.listType(:,1);
co_trials = listType<2;
sh_trials = listType==2;
% CONTROL
data_co = trial_subset(co_trials,data);
% SHIFT
data_sh = trial_subset(sh_trials,data);


% prep data for relabeled controls
sh_mask_intrusions = make_mask_exclude_intrusions2d(data_sh.recalls);
rec_task = create_rec_labels(data_sh.pres_task, data_sh.recalls, ...
                             sh_mask_intrusions);
% create relabeled controls
mult_subj = 5;
relab_recalls = repmat(data_co.recalls, mult_subj, 1);
relab_mask = make_clean_recalls_mask2d(relab_recalls);
relab_subj = repmat(data_co.subject, mult_subj, 1);

relab_mask_intrusions = make_mask_exclude_intrusions2d(relab_recalls);
relab_pres_task = create_relabeled_trials(size(relab_recalls,1), data_sh.pres_task);
relab_rec_task = create_rec_labels(relab_pres_task, relab_recalls, relab_mask_intrusions);

%%%%%%%
% CRP %
%%%%%%%

rec_mask = make_clean_recalls_mask2d(data.recalls);

% output positions 1-3
% transitions originating from serial positions 5-19 are considered
op_mask = rec_mask;
op_mask(:,4:end) = false;
lowermask = data.recalls >=5;
uppermask = data.recalls <=19;
from_mask = op_mask & lowermask & uppermask;
to_mask = rec_mask;
bins = [-19 -17 -5 -1 0 1 2 6 18 20];
crps_op1_3 = bin_crp(data.recalls, data.subject, listLength, bins, ...
                     from_mask, to_mask);
% remove last irrelevant bin
crps_op1_3 = crps_op1_3(:,1:end-1);

res.crp.op1_3 = nanmean(crps_op1_3,1);

xbin = [-18.5 -11.5 -3.5 -1 0 1 3.5 11.5 18.5];
% plot
figure(fignum)
fignum = fignum+1;
param = struct();
param.title = 'CRP O.P. 1-3';
param.xlabel = struct('label','Mean lag');
param.xtick = xbin(xbin~=0); % tick all bins but zero
param.ylabel = struct('label','Conditional Response Probability');
param.xlim = [-20 20];
param.ylim = [0 0.3];
plot_general(xbin, res.crp.op1_3, param);

% output positions 4+
% transitions originating from serial positions 5-19 are considered
op_mask = rec_mask;
op_mask(:,1:3) = false;
lowermask = data.recalls >=5;
uppermask = data.recalls <=19;
from_mask = op_mask & lowermask & uppermask;
to_mask = rec_mask;
bins = [-19 -17 -5 -1 0 1 2 6 18 20];
crps_op4on = bin_crp(data.recalls, data.subject, listLength, bins, ...
                     from_mask, to_mask);
% remove last irrelevant bin
crps_op4on = crps_op4on(:,1:end-1);

res.crp.op4on = nanmean(crps_op4on,1);

xbin = [-18.5 -11.5 -3.5 -1 0 1 3.5 11.5 18.5];
% plot
figure(fignum)
fignum = fignum+1;
param = struct();
param.title = 'CRP O.P. 4+';
param.xlabel = struct('label','Mean lag');
param.xtick = xbin(xbin~=0); % tick all bins but zero
param.ylabel = struct('label','Conditional Response Probability');
param.xlim = [-20 20];
param.ylim = [0 0.3];
plot_general(xbin, res.crp.op4on, param);

%%%%%%%%%%%%%%%%%
% SOURCE FACTOR %
%%%%%%%%%%%%%%%%%

% shift
sh_mask = make_clean_recalls_mask2d(data_sh.recalls);
srcfacts = source_fact(rec_task, data_sh.subject, sh_mask);
res.srcfact.sh = nanmean(srcfacts,1);
res.srcfact.sh_sem = nanstd(srcfacts,1)/sqrt(nsubj-1);
% relabeled controls
relab_srcfacts = source_fact(relab_rec_task, relab_subj, ...
                             relab_mask);
res.srcfact.relab = nanmean(relab_srcfacts,1);
res.srcfact.relab_sem = nanstd(relab_srcfacts,1)/sqrt(nsubj-1);

%%%%%%%%%%%%%%%%%%%%%%%%
% REMOTE SOURCE FACTOR %
%%%%%%%%%%%%%%%%%%%%%%%%

% shift
sh_task_train = trains_from_categories(data_sh.pres_task);
srcfacts_remote = source_fact_remote(data_sh.pres_task, sh_task_train, ...
                                data_sh.recalls, data_sh.subject);
res.rem_srcfact.sh = nanmean(srcfacts_remote,1);
res.rem_srcfact.sh_sem = nanstd(srcfacts_remote,1)/sqrt(nsubj-1);
% relabeled controls
relab_pres_trainno = trains_from_categories(relab_pres_task);
relab_srcfacts_remote = source_fact_remote(relab_pres_task, ...
                                           relab_pres_trainno, ...
                                           relab_recalls, ...
                                           relab_subj);
res.rem_srcfact.relab = nanmean(relab_srcfacts_remote,1);
res.rem_srcfact.relab_sem = nanstd(relab_srcfacts_remote,1)/sqrt(nsubj-1);

%%%%%%%%%%%%%
% TRAIN CRP %
%%%%%%%%%%%%%

% shift
intr_mask = make_mask_exclude_intrusions2d(data_sh.recalls);
sh_pres_trainno = trains_from_categories(data_sh.pres_task);
sh_crp_train = train_crp(data_sh.recalls, sh_pres_trainno, ...
                      data_sh.subject, listLength, intr_mask);
res.train_crp.sh = nanmean(sh_crp_train,1);
% relabeled controls
intr_mask = make_mask_exclude_intrusions2d(relab_recalls);
relab_pres_trainno = trains_from_categories(relab_pres_task);
relab_crp_train = train_crp(relab_recalls, relab_pres_trainno, ...
                            relab_subj, listLength, intr_mask);
res.train_crp.relab = nanmean(relab_crp_train,1);

% plot
figure(fignum)
fignum = fignum+1;
param = struct();
param.title = 'Train CRP';
param.xlabel = struct('label','Train Lag');
param.legend = {'Relab. Control' 'Task-shift' 'Location' ...
                'Northeast'};
param.linetype = {'-' '-'};
param.marker = {'o' '^'};
param.xtick = [-4:4];
param.ylim = [0 0.5];
param.cols = [3:11];
plot_crp({res.train_crp.relab res.train_crp.sh},param);

%%%%%%%%%%%%%
% TRAIN SPC %
%%%%%%%%%%%%%
sh_spc_train = train_spc(data_sh.recalls, data_sh.pres_task, ...
                         data_sh.subject, listLength);
res.train_spc.sh = nanmean(sh_spc_train,1);
relab_spc_train = train_spc(relab_recalls, relab_pres_task, ...
                            relab_subj, listLength);
res.train_spc.relab = nanmean(relab_spc_train,1);

% plot
figure(fignum)
fignum = fignum+1;
param = struct();
param.title = 'Train SPC';
param.xlabel = struct('label','Train Number');
param.legend = {'Relab. Control' 'Task-shift' 'Location' ...
                'Northwest'};
param.linetype = {'-' '-'};
param.marker = {'o' '^'};
param.ylim = [0.2 0.9];
plot_spc({res.train_spc.relab res.train_spc.sh}, param);


%%%%%%%%%%%%%%
% SHIFT COST %
%%%%%%%%%%%%%%

% control data used to analyze semantic and temporal effects
rec_mask = make_clean_recalls_mask2d(data_co.recalls);
% output positions 1-8
op_mask = rec_mask;
op_mask(:,10:end) = false;

co_mask_intrusions = make_mask_exclude_intrusions2d(data_co.recalls);
co_rec_task = create_rec_labels(data_co.pres_task, data_co.recalls, ...
                                co_mask_intrusions);

irts = shift_cost(data_co.recalls, data_co.times, data_co.rec_itemnos, ...
                     co_rec_task, data_co.subject, sem_mat, ...
                     op_mask);

% shift data used to analyze source effects
rec_mask = make_clean_recalls_mask2d(data_sh.recalls);
% output transitions 1-8
op_mask = rec_mask;
op_mask(:,10:end) = false;

source = shift_cost(data_sh.recalls, data_sh.times, ...
                    data_sh.rec_itemnos, rec_task, data_sh.subject, ...
                    sem_mat, op_mask);

% semantic effect
shift_ls = nanmean(irts.sem_diff);
shift_hs = nanmean(irts.sem_sim);
sem_subj = nanmean(irts.sem_diff - irts.sem_sim, 2);
res.shiftcost.sem = nanmean(sem_subj);
res.shiftcost.sem_sem = nanstd(sem_subj)/sqrt(nsubj-1);

% temporal effect
shift_fl = nanmean(irts.lag_diff);
shift_nl = nanmean(irts.lag_sim);
lag_subj = nanmean(irts.lag_diff - irts.lag_sim, 2);
res.shiftcost.tmp = nanmean(lag_subj);
res.shiftcost.tmp_sem = nanstd(lag_subj)/sqrt(nsubj-1);

% source effect
shift_sh = nanmean(source.task_diff);
shift_rp = nanmean(source.task_sim);
task_subj = nanmean(source.task_diff - source.task_sim, 2);
res.shiftcost.src = nanmean(task_subj);
res.shiftcost.src_sem = nanstd(task_subj)/sqrt(nsubj-1);




% SUBFUNCTIONS %

function [all_p_rec] = train_spc(recalls_matrix, pres_source, subjects, ...
    list_length, mask)
% TRAIN_SPC  Computes probability of recall for each of a series of
%   serial position groups.  The output is organized in terms of the
%   groups.  If a particular trial has no observations for a
%   particular group then a NaN is inserted for that trial.  Groups
%   do not need to be consecutive, and do not need to start from
%   1, however the code 0 is used for items that do not belong to
%   any group.
%
%   [all_p_rec] = train_spc(recalls_matrix, pres_source, subjects, list_length, ...
%                             mask)
%
% INPUTS:
%  recalls_matrix:  a matrix whose elements are serial positions of recalled
%                   items.  The rows of this matrix should represent recalls
%                   made by a single subject on a single trial.
%
%     pres_source:  a matrix indexing the source associated with each
%                   presented item.
%
%        subjects:  a column vector which indexes the rows of recalls_matrix
%                   with a subject number (or other identifier).  That is, 
%                   the recall trials of subject S should be located in
%                   recalls_matrix(find(subjects==S), :)
%
%     list_length:  a scalar indicating the number of serial positions in the
%                   presented lists.  serial positions are assumed to run 
%                   from 1:list_length.
%
%            mask:  if given, a logical matrix of the same shape as 
%                   recalls_matrix, which is false at positions (i, j) where
%                   the value at recalls_matrix(i, j) should be excluded from
%                   the calculation of the probability of recall.  If NOT
%                   given, a standard clean recalls mask is used, which 
%                   excludes repeats, intrusions and empty cells
%  OUTPUTS:
%        all_p_rec: a matrix of probablities.  Its columns are indexed by
%                   serial position and its rows are indexed by subject.
%

% sanity checks
if ~exist('recalls_matrix', 'var')
  error('You must pass a recalls matrix.')
end
if ~exist('pres_source', 'var')
  error('You must pass a source matrix.')
end
if ~exist('subjects', 'var')
  error('You must pass a subjects vector.')
end
if ~exist('list_length', 'var')
  error('You must pass a list length.')
end
if ~exist('mask', 'var')
  % create standard clean recalls mask if none was given
  mask = make_clean_recalls_mask2d(recalls_matrix);
end
if size(mask) ~= size(recalls_matrix)
  error('recalls matrix and mask must have the same shape.')
end
if size(recalls_matrix, 1) ~= length(subjects)
  error('recalls matrix must have the same number of rows as subjects.')
end

groups = trains_from_categories(pres_source);
temp_data = struct('recalls', recalls_matrix, ...
		   'subject', subjects, ...
		   'groups', groups);

% Defines the train length      
trials6 = temp_data.groups(:,24)== 6;
trials7 = temp_data.groups(:,24)== 7;

data6 = trial_subset(trials6,temp_data);
data7 = trial_subset(trials7,temp_data);

% Behavioral toolbox script that calculates spc by group,
% which is train in this case
p_rec6 = group_spc(data6.recalls, ...
		   data6.groups, ... 
		   data6.subject, list_length);   
p_rec7 = group_spc(data7.recalls, ...
		   data7.groups, ... 
		   data7.subject, list_length);    

p_rec6pad = [p_rec6(:,1:3) NaN(size(p_rec6,1),1) p_rec6(:,4:6)];

all_p_rec = [p_rec6pad; p_rec7];

%end function


function [irts] = shift_cost(recalls_matrix, times, rec_itemnos, ...
    task, subject, sem_mat, mask)
% SHIFT COST  Computes the shift costs of IRTs for semantic, temporal, and
% task between dissimilar and similar transitions
%
% [irts] = shift_cost(recalls_matrix, times, rec_itemnos, ...
%   task, subject, sem_mat, mask)
%
% INPUTS:
%  recalls_matrix:  a matrix whose elements are serial positions of recalled
%                   items.  The rows of this matrix should represent recalls
%                   made by a single subject on a single trial.
%
%          times:   a matrix where each column specifies the time a
%                   particular item was recalled.  Each
%                   row represents a particular trial.
%
%    rec_itemnos:   a matrix where each column specifies the item number of
%                   a particular item that was recalled.  Each
%                   row represents a particular trial.
%
%          task:    a matrix where each column specifies the type of task
%                   from that recalled item.  Each
%                   row represents a particular trial.
%
%        subjects:  a column vector which indexes the rows of recalls_matrix
%                   with a subject number (or other identifier).  That is, 
%                   the recall trials of subject S should be located in
%                   recalls_matrix(find(subjects==S), :)
%
%          sem_mat: a matrix with the values of the strengths of
%                   associations between words
%
%            mask:  if given, a logical matrix of the same shape as 
%                   recalls_matrix, which is false at positions (i, j) where
%                   the value at recalls_matrix(i, j) should be excluded from
%                   the calculation of the probability of recall.  If NOT
%                   given, a standard clean recalls mask is used, which 
%                   excludes repeats, intrusions and empty cells
%  OUTPUTS:
%           irts:   a structure of irts organized by the type of irt
%

% sanity checks:
if ~exist('recalls_matrix', 'var')
  error('You must pass a recalls matrix.')
elseif ~exist('subject', 'var')
  error('You must pass a subjects vector.')
elseif ~exist('times', 'var')
  error('You must pass a times matrix.')
elseif ~exist('rec_itemnos', 'var')
  error('You must pass a recalled item numbers matrix.')
elseif ~exist('task', 'var')
  error('You must pass a task matrix.')
elseif ~exist('sem_mat', 'var')
  error('You must pass a semantic matrix.')
elseif size(recalls_matrix, 1) ~= length(subject)
  error('recalls matrix must have the same number of rows as subjects.')
elseif ~exist('mask', 'var')
  % create standard clean recalls mask if none was given
  mask = make_clean_recalls_mask2d(recalls_matrix);
end
if size(mask) ~= size(recalls_matrix)
  error('recalls_matrix and mask must have the same shape.')
end
  
maxop = max(sum(mask,2));
subjects = unique(subject);
numsubj = length(subjects);

irts.sem_sim = NaN(numsubj, maxop-1);
irts.sem_diff = NaN(numsubj, maxop-1);

irts.lag_sim = NaN(numsubj, maxop-1);
irts.lag_diff = NaN(numsubj, maxop-1);

irts.task_sim = NaN(numsubj, maxop-1);
irts.task_diff = NaN(numsubj, maxop-1);


for s = 1:numsubj
    
    thisubj = subjects(s);
    % find the position in the RECALLS matrix for subject == s and
    % put that subjects data into recalls_subj and other matrices (time)
    recalls_subj = recalls_matrix(find(subject==thisubj),:);
    task_subj = task(find(subject==thisubj),:);
    times_subj= times(find(subject==thisubj),:);
    recitems_subj = rec_itemnos(find(subject==thisubj),:);
    mask_subj = mask(find(subject==thisubj),:);
    
    numtrials = size(recalls_subj, 1);
    
    sem_d = NaN(numtrials, maxop-1);
    sem_s = NaN(numtrials, maxop-1);
    lag_d = NaN(numtrials, maxop-1);
    lag_s = NaN(numtrials, maxop-1);
    task_d = NaN(numtrials, maxop-1);
    task_s = NaN(numtrials, maxop-1);

    % goes through rows (lists) of recalls_subj matrix
    for rows=1:numtrials
    
        % goes through columns of recalls_subj matrix
        for cols=1:size(recalls_subj, 2)-1 
            start_recall = recalls_subj(rows,cols);   % word position 1
            end_recall = recalls_subj(rows,cols+1); % word position 2
            op = sum(mask_subj(rows,1:cols));
      
            % test to see if we count transition
            if mask_subj(rows,cols) && mask_subj(rows,cols+1)
        
                lag = end_recall - start_recall;
                irt = times_subj(rows, cols+1) - times_subj(rows,cols);
                task_diff = task_subj(rows, cols+1) - task_subj(rows,cols);
                sem = sem_mat(recitems_subj(rows, cols+1), recitems_subj(rows,cols));
            
                % Test for semantic clustering
                if sem < .2
                    % Finds the next available spot to add the irt
                    row = min(find(isnan(sem_d(:,op))));
                    sem_d(row, op) = irt;
                else
                    row = min(find(isnan(sem_s(:,op))));
                    sem_s(row, op) = irt;
                end
                
                % Test for temporal clustering
                if lag > 3
                    row = min(find(isnan(lag_d(:,op))));
                    lag_d(row, op) = irt;
                else
                    row = min(find(isnan(lag_s(:,op))));
                    lag_s(row, op) = irt;
                end
                
                % Test for source clustering
                if task_diff ~= 0
                    row = min(find(isnan(task_d(:,op))));
                    task_d(row, op) = irt;
                else
                    row = min(find(isnan(task_s(:,op))));
                    task_s(row, op) = irt;
                end
            end
      
        end % stops COLS
    
    end % stops ROWS
        
    irts.sem_sim(s,:) = nanmean(sem_s);
    irts.sem_diff(s,:) = nanmean(sem_d);
    irts.lag_sim(s,:) = nanmean(lag_s);
    irts.lag_diff(s,:) = nanmean(lag_d);
    irts.task_sim(s,:) = nanmean(task_s);
    irts.task_diff(s,:) = nanmean(task_d);
  
end % subjects

%endfunction
