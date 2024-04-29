function param = param_cmr_full
% param = param_cmr_full
%
% This function creates a parameters structure for use with the CMR
% model.  Update param.sem_path to reflect the local path to the
% semantic similarity file.
%
% These parameters were found using a genetic algorithm fitting
% procedure and are reported in Table 1 of the Polyn et
% al. manuscript, parameter set Full.
%
% Note that a conversion is needed between the values for eta
% and tau reported here and those appearing in the manuscript.
% See README.txt, FAQ Q1.
%
% % Example:
% param = param_cmr_full;
%

param.subregions = 2;
param.not_presented_indices{1} = [];
param.not_presented_indices{2} = [];

param.custom_context_fn{1} = @context_update;
param.custom_context_fn{2} = @context_update;
param.pres_item_fn = @present_item_p09;
param.recall_task_fn = @fr_task;
param.reac_item_fn = @reactivate_item_p09;
param.post_recall_decision = 0;
param.reset = 1;
param.can_repeat = 0;
param.alpha = 0;
param.omega = 0;

param.B_enc_temp = .77;
param.B_enc_source = .59;
param.B_rec_temp = .51;
param.B_rec_source = .59;

param.B_enc = [0.77 0.59];
param.B_rec = [0.51 0.59];
param.p_scale = 1.07;
param.p_decay = 0.98;
param.gamma_fc = 0.898;
param.lrate_fc_enc = [param.gamma_fc param.gamma_fc; 0 0];

param.task_lrate_cf = 0.129;
param.base_lrate_cf = 1;
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
param.dt_tau = param.dt / param.tau;
param.sq_dt_tau = sqrt(param.dt_tau);
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
param.do_dfr = 0;

param.do_shift = 1;
param.shift_trigger_regions = [0 1];
param.shift_disrupt_regions = [1 0];
param.d = 0.77;
param.shift_schedule = [0.77 0];

param.do_end_list = 0;

% new params
param.sem_assoc_mats = {{'cf'},{}};
param.save_context = false;
param.c_in_norm = [1 1];

