function [data, net] = run_fr(subject)
%
%   RUN_FR
%
% subject = [1; 1];
%
param.subregions = 2;
param.n_patterns = [];
param.not_presented_indices{1} = [];
param.not_presented_indices{2} = [];

param.B_enc = [0.77 0.59];
param.B_rec = [0.51 0.59];
param.p_scale = 1;
param.p_decay = 1;
param.gamma_fc = 0.898;
param.lrate_fc_enc = [param.gamma_fc param.gamma_fc; 0 0];
param.lrate_cf_enc = [1 0; 0.129 0];
param.lrate_fc_rec = [0 0; 0 0];
param.lrate_cf_rec = [0 0; 0 0];
param.eye_fc = 1 - param.gamma_fc;
param.eye_cf = 0;
param.s = 0.8;
param.K = 0.05;
param.L = 0.17;
param.eta = 0.380;
param.tau = 570;
param.dt = 100;
param.thresh = 1;
param.support_thresh = 0.0001;

param.rec_time = 90000;
param.recall_regions = [1 0];

param.init_orthogonal_index = [1 0];
param.has_semantic_structure = [1 0];
param.sem_path{1} = '~/matlab_code/svn/CMR_sims/trunk/LSA_tfr.mat';
param.sem_path{2} = '';
param.orthogonal_patterns = 1;

param.do_cdfr = 1;
param.cdfr_disrupt_regions = [1 0];
param.cdfr_schedule = ones(16,12) * 0.3;

param.do_dfr = 1;
param.dfr_disrupt_regions = [1 0];
param.dfr_schedule = ones(16,1) * 0.3;

param.do_shift = 1;
param.shift_trigger_regions = [0 1];
param.shift_disrupt_regions = [1 0];
param.shift_schedule = [0.77 0];

param.do_end_list = 1;
param.end_disrupt_regions = [1 0];
param.end_schedule = ones(16,1) * 0.3;

item_indices = 1:(12*16);
param.pres_indices(:,:,1) = reshape(item_indices,12,16)';
param.pres_indices(:,:,2) = ones(16,12);
param.pres_indices(:,7:12,2) = 2;

param.not_presented_indices{1} = [];
param.not_presented_indices{2} = [];

rand('state',sum(100*clock));

num_trials = size(param.pres_indices,1);
list_length = size(param.pres_indices,2);

% determine the appropriate number of dimensions
if isempty(param.n_patterns)
  [param.n_patterns param.first_distraction_index] ...
      = calculate_session_patterns(param);
  if param.orthogonal_patterns
    param.n_dimensions = param.n_patterns;
  end
end

for i = 1:length(subject)
  session(i) = simulate_fr(param);
end

% stitch sessions into a larger data structure
data.subject = [];
data.session = [];

f = fieldnames(session(1));
for i = 1:length(f)
  data.(f{i}) = [];
end

% find max number of columns
maxcols = 0;
for i = 1:length(session)
  ncols = size(session(i).recalls,2);
  maxcols = max(ncols, maxcols);
end

for i = 1:length(session)
  this_subject = ones(num_trials,1) * subject(i);
  this_session = ones(num_trials,1) * sum(subject(1:i)==subject(i));
  data.subject = [data.subject; this_subject];
  data.session = [data.session; this_session];
  for j = 1:length(f)
    this_field = session(i).(f{j});
    ncols = size(this_field,2);
    if ncols < maxcols
      this_field(:,ncols+1:maxcols) = 0;
    end
    data.(f{j}) = [data.(f{j}); this_field];
  end
end

