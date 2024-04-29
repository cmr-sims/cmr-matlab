function res = analyze_taskFR(data, sem_mat, noise_mat)
% res = analyze_taskFR(data, sem_mat, noise_mat)
% ANALYZE_TASKFR
% Various analyses for the TaskFR paradigm
%
% INPUTS:
%       data: behavioral data from the experiment or the model
%
%    sem_mat: LSA matrix containing the similarity scores between
%             all studied items
%
%  noise_mat: optional matrix of Gaussian noise to correct the
%             estimates of semantic clustering produced by the CMR
%             model
%
% OUTPUTS:
%        res: structure containing the result of the analyses
%          - semfact:     mean semantic factor
%          - semfact_sem: standard error of semantic factor
%          - tmpfact:     mean temporal factor
%          - tmpfact_sem: standard error of temporal factor
%          - crp:         conditional response probability by lag
%             - op1_3:       for output positions 1-3
%             - op4on:       for output positions 4+
%          - spc:         recall probability by serial position
%             - op1:         for first output position
%             - op2:         for second output position
%             - op3:         for third output position
%             - co:          for control trials
%             - sh:          for task-shift trials
%                           
%
% DEPENDENCY:
%    Behavioral Toolbox (Release 1)
%    http://memory.psych.upenn.edu/behavioral_toolbox
%
% USAGE:
%    To run the analyses on the PolyEtal09 data, pass in the 'full'
%    substructure of the data structure rather than the whole data
%    structure, like below:
%    res = analyze_taskFR(data.full, sem_mat);
%
%    To run the analyses on the CMR results, apply an additional
%    noise matrix to sem_mat, like below:
%    noise_var = 0.41;
%    noise_mat = sqrt(noise_var)*randn(size(sem_mat));
%    res = analyze_taskFR(data, sem_mat, noise_mat);

% sanity checks
if ~exist('data','var')
  error('You must pass a data structure.')
elseif ~exist('sem_mat','var')
  error('You must pass a similarity matrix.')
end

if ~exist('noise_mat','var')
  noise_mat = zeros(size(sem_mat));
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
%data_co = trial_subset(co_trials,data);
data_co.subject = data.subject(co_trials,:);
data_co.recalls = data.recalls(co_trials,:);
data_co.rec_itemnos = data.rec_itemnos(co_trials,:);
data_co.times = data.times(co_trials,:);
data_co.listType = data.listType(co_trials,:);
data_co.pres_itemnos = data.pres_itemnos(co_trials,:);
data_co.pres_task = data.pres_task(co_trials,:);

% SHIFT
%data_sh = trial_subset(sh_trials,data);
data_sh.subject = data.subject(sh_trials,:);
data_sh.recalls = data.recalls(sh_trials,:);
data_sh.rec_itemnos = data.rec_itemnos(sh_trials,:);
data_sh.times = data.times(sh_trials,:);
data_sh.listType = data.listType(sh_trials,:);
data_sh.pres_itemnos = data.pres_itemnos(sh_trials,:);
data_sh.pres_task = data.pres_task(sh_trials,:);

%%%%%%%%%%%%%%%%%%%
% SEMANTIC FACTOR %
%%%%%%%%%%%%%%%%%%%

% corrected LSA matrix adds noise_mat to sem_mat
% if no noise_mat was passed, corrected_sem_mat = sem_mat
corrected_sem_mat = sem_mat+noise_mat;
semfacts = dist_fact(data.rec_itemnos, data.pres_itemnos, data.subject, ...
                     corrected_sem_mat);
res.semfact = nanmean(semfacts,1);
res.semfact_sem = nanstd(semfacts,1)/sqrt(nsubj-1);

%%%%%%%%%%%%%%%%%%%
% TEMPORAL FACTOR %
%%%%%%%%%%%%%%%%%%%

tmpfacts = temp_fact(data.recalls, data.subject, listLength);
res.tmpfact = nanmean(tmpfacts,1);
res.tmpfact_sem = nanstd(tmpfacts,1)/sqrt(nsubj-1);

%%%%%%%
% CRP %
%%%%%%%

rec_mask = make_clean_recalls_mask2d(data.recalls);

% output positions 1-3
% transitions originating from serial positions 5-19 are considered
op_mask = rec_mask;
op_mask(:,4:end) = false;
from_mask = op_mask;
to_mask = rec_mask;
crps_op1_3 = lag_crp(data.recalls, data.subject, listLength, from_mask, ...
                     to_mask);

res.crp.op1_3 = nanmean(crps_op1_3,1);

% plot
figure(fignum)
fignum = fignum+1;
param = struct();
param.title = 'CRP O.P. 1-3';
param.linetype = {'-'};
param.marker = 'o';
param.ylim = [0 0.3];
plot_crp(res.crp.op1_3,param);


% output positions 4+
% transitions originating from serial positions 5-19 are considered
op_mask = rec_mask;
op_mask(:,1:3) = false;
from_mask = op_mask;
to_mask = rec_mask;
crps_op4on = lag_crp(data.recalls, data.subject, listLength, from_mask, ...
                     to_mask);

res.crp.op4on = nanmean(crps_op4on,1);

% plot
figure(fignum)
fignum = fignum+1;
param = struct();
param.title = 'CRP O.P. 4+';
param.linetype = {'-'};
param.marker = 'o';
param.ylim = [0 0.3];
plot_crp(res.crp.op4on,param);

%%%%%%%
% SPC %
%%%%%%%

rec_mask = make_clean_recalls_mask2d(data.recalls);

% first output position
op_mask = rec_mask;
op_mask(:,2:end) = false;
spc_op1 = spc(data.recalls, data.subject, listLength, op_mask);
res.spc.op1 = nanmean(spc_op1,1);

% second output position
op_mask = rec_mask;
op_mask(:,1) = false;
op_mask(:,3:end) = false;
spc_op2 = spc(data.recalls, data.subject, listLength, op_mask);
res.spc.op2 = nanmean(spc_op2,1);

% third output position
op_mask = rec_mask;
op_mask(:,1:2) = false;
op_mask(:,4:end) = false;
spc_op3 = spc(data.recalls, data.subject, listLength, op_mask);
res.spc.op3 = nanmean(spc_op3,1);

% control and shift SPC's
spcs_co = spc(data_co.recalls, data_co.subject, listLength);
spcs_sh = spc(data_sh.recalls, data_sh.subject, listLength);

res.spc.co = nanmean(spcs_co,1);
res.spc.sh = nanmean(spcs_sh,1);

% plot
figure(fignum)
fignum = fignum+1;
param = struct();
param.title = 'SPC';
param.legend = {'Control' 'Shift' 'Location' 'Northwest'};
param.linetype = {'-' '-'};
param.marker = {'o' '^'};
plot_spc({res.spc.co res.spc.sh},param);
