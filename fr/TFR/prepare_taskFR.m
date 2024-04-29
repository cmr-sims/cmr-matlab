function [data,net] = prepare_taskFR(param,datapath)
% [data,net] = prepare_taskFR(param,datapath);
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
% datapath = '~/CMR_sims/data.mat';
% [data,net] = prepare_taskFR(param,datapath); 
%
% THIS CAN BE REMOVED FROM THE POSTED VERSION:
%
% On SERVO:
% datapath = '/Users/polyn/SCIENCE/EXPERIMENTS/apem_e7/results/data.mat';
%
% gaparam = ga_param_full1;
% param = param_conversion(h.best_param,gaparam,'param');
% param.semPath = '/Users/polyn/SCIENCE/SIMULATION/CMR_sims/LSA_tfr.mat';
%
% [data,net] = prepare_taskFR(param,datapath);
%

rand('state',sum(100*clock));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load the experimental data %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load(datapath);
fprintf('experimental data loaded.\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load semantic connections if needed %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if param.s > 0
  load(param.semPath);
  param.semMat = LSA;
  fprintf('semantic connections loaded.\n');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% prepare to create data structure %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

LL = data.full.listLength;

% mult_subj is a parameter which controls how many lists will be
% run. mult_subj == 1 runs as many simulated trials as in the
% original experiment, with larger numbers running that multiple of
% the number of trials.
% n_co and n_sh may differ
nLists_co = size(data.co.recalls,1);
nLists_sh = size(data.sh.recalls,1);
getNLists_co = size(data.co.recalls,1) * param.mult_subj;
getNLists_sh = size(data.sh.recalls,1) * param.mult_subj;

listOrder_co = repmat([1:nLists_co]',param.mult_subj,1);
listOrder_sh = repmat([1:nLists_sh]',param.mult_subj,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create the network data structure %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% THE CONTROL LISTS
data.net.co.listLength = LL;
% these fields are copied
data.net.co.subject = data.co.subject(listOrder_co);
max_subj = max(data.net.co.subject);
for i = 1:param.mult_subj
  start = ((i-1)*nLists_co)+1;
  last = start + nLists_co - 1;
  data.net.co.subject(start:last) = data.net.co.subject(start:last) + (max_subj*(i-1));  
end
data.net.co.session = data.co.session(listOrder_co);
data.net.co.listType = data.co.listType(listOrder_co);
data.net.co.pres_task = data.co.pres_task(listOrder_co,:);
data.net.co.pres_itemnos = data.co.pres_itemnos(listOrder_co,:);
% these fields are filled by running the network
data.net.co.recalls = zeros(getNLists_co,LL);
data.net.co.task = NaN(getNLists_co,LL);
data.net.co.times = zeros(getNLists_co,LL);
data.net.co.intrusions = zeros(getNLists_co,LL);
data.net.co.rec_itemnos = zeros(getNLists_co,LL);

% placeholder field
data.net.co.react_time = zeros(getNLists_co,LL);

% THE SHIFT LISTS
data.net.sh.listLength = LL;
% these fields are copied
data.net.sh.subject = data.sh.subject(listOrder_sh);
max_subj = max(data.net.sh.subject);
for i = 1:param.mult_subj
  start = ((i-1)*nLists_sh)+1;
  last = start + nLists_sh - 1;
  data.net.sh.subject(start:last) = data.net.sh.subject(start:last) + (max_subj*(i-1));  
end
data.net.sh.session = data.sh.session(listOrder_sh);
data.net.sh.listType = data.sh.listType(listOrder_sh);
data.net.sh.pres_task = data.sh.pres_task(listOrder_sh,:);
data.net.sh.pres_itemnos = data.sh.pres_itemnos(listOrder_sh,:);
% these fields are filled by running the network
data.net.sh.recalls = zeros(getNLists_sh,LL);
data.net.sh.task = NaN(getNLists_sh,LL);
data.net.sh.times = zeros(getNLists_sh,LL);
data.net.sh.intrusions = zeros(getNLists_sh,LL);
data.net.sh.rec_itemnos = zeros(getNLists_sh,LL);

% placeholder field
data.net.sh.react_time = zeros(getNLists_sh,LL);

%%%%%%%%%%%%%%%%%%%%
% run the paradigm %
%%%%%%%%%%%%%%%%%%%%

if ~param.justControl
  fprintf('Running the shift lists.\n');
  [net,data.net.sh] = simulate_CMR(param,data.net.sh);
  [data.net.sh] = task_info(data.net.sh);
end

fprintf('Running the control lists.\n');

[net,data.net.co] = simulate_CMR(param,data.net.co);
[data.net.co] = task_info(data.net.co);

% make the fake subjects for all the standard analyses
% requires both sh and co fields
[data.net] = make_fake_subjs(data.net);


