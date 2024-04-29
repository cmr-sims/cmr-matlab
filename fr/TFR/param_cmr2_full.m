function param = param_cmr2_full
%
% PARAM_CMR2_FULL
%

param.subregions = 2;
param.n_patterns = [];
param.not_presented_indices{1} = [];
param.not_presented_indices{2} = [];

param.custom_context_fn{1} = @context_update;
param.custom_context_fn{2} = @context_update;
param.recall_task_fn = @fr_task;
param.post_recall_decision = 0;
param.reset = 1;
param.can_repeat = 0;
param.alpha = 0;
param.omega = 0;

param.B_enc = [0.77 0.59];
param.B_rec = [0.51 0.59];
param.p_scale = 1.07;
param.p_decay = 0.98;
param.gamma_fc = 0.898;
param.lrate_fc_enc = [param.gamma_fc param.gamma_fc; 0 0];
param.lrate_cf_enc = [1 0; 0.129 0];
param.lrate_fc_rec = [0 0; 0 0];
param.lrate_cf_rec = [0 0; 0 0];
param.eye_fc = 1 - param.gamma_fc;
param.eye_cf = 0;
param.s = 2.78;
param.K = 0.111;
param.L = 0.338;
param.eta = 0.380;
param.tau = 574;
param.dt = 100;
param.thresh = 1;
param.support_thresh = 0.0001;

param.rec_time = 90000;
param.recall_regions = [1 0];

param.init_orthogonal_index = [1 0];
param.has_semantic_structure = [1 0];
param.sem_path{1} = 'LSA_tfr.mat';
param.sem_path{2} = '';
param.on_diag = 0;
param.orthogonal_patterns = 1;

param.do_cdfr = 0;
param.cdfr_disrupt_regions = [1 0];
param.cdfr_schedule = ones(1,12) * 0;

param.do_dfr = 0;
param.dfr_disrupt_regions = [1 0];
param.dfr_schedule = ones(1,1) * 0;

param.do_shift = 1;
param.shift_trigger_regions = [0 1];
param.shift_disrupt_regions = [1 0];
param.shift_schedule = [0.77 0];

param.do_end_list = 0;
param.end_disrupt_regions = [1 0];
param.end_schedule = ones(1,1) * 0.3;

