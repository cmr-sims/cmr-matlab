
subject = ones(32,1);
session = ones(32,1);
session(17:32,1) = session(17:32,1) * 2;

param.subregions = 2;
param.n_patterns = [];
param.single_list = 1;

param.B_enc = [0.77 0.59];
param.B_rec = [0.51 0.59];
param.p_scale = 1;
param.p_decay = 1;
param.gamma_fc = 0.898;
param.lrate_fc = [param.gamma_fc param.gamma_fc; 0 0];
param.lrate_cf = [1 0; 0.129 0];
param.eye_fc = 1 - param.gamma_fc;
param.eye_cf = 0;
param.s = 2.78;
param.K = 0.111;
param.L = 0.338;
param.eta = 0.380;
param.tau = 570;
param.dt = 100;
param.thresh = 1;
param.support_thresh = 0.0001;

param.rec_time = 90000;
param.recall_regions = [1 0];

param.init_orthogonal_index = [1 0];
param.has_semantic_structure = [1 0];
param.sem_path{1} = '~/SCIENCE/SIMULATION/CMR_multilist_branch/LSA_tfr.mat';
param.sem_path{2} = '';
param.orthogonal_patterns = 1;

param.do_cdfr = 1;
param.cdfr_disrupt_regions = [1 0];
param.cdfr_schedule = ones(1,12) * 0.3;

param.do_dfr = 1;
param.dfr_disrupt_regions = [1 0];
param.dfr_schedule = ones(1,1) * 0.3;

param.do_shift = 1;
param.shift_trigger_regions = [0 1];
param.shift_disrupt_regions = [1 0];
param.shift_schedule = [0.77 0];

param.do_end_list = 0;
param.end_disrupt_regions = [1 0];
param.end_schedule = ones(1,1) * 0.3;

param.pres_indices = zeros(1,12,2);
item_indices = 1:(12*1);
param.pres_indices(:,:,1) = item_indices;
param.pres_indices(:,:,2) = ones(1,12);
param.pres_indices(:,7:12,2) = 2;


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
  [net,res(i)] = simulate_fr(param);
end

