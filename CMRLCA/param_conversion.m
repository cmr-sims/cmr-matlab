function out = param_conversion(p, gaparam, to_what)
%PARAM_CONVERSION   Convert parameters between vector and struct format.
%
%  param_vec = param_conversion(param_struct, gaparam, 'vector')
%
%   OR
%
%  param_struct = param_conversion(param_vec, gaparam, 'param')
%
% Example:
% param = param_taskFR1;
% vec = param_conversion(param,gaparam,'vector');
%
% gaparam = ga_param_rev1;
% param = param_conversion(h.best_param,gaparam,'param');

if strcmp(to_what,'vector')
  % copy over the parameters that the minimization function should be
  % allowed to mess with.
  for i=1:length(gaparam)
    vec(gaparam(i).vector_index) = p.(gaparam(i).name);
  end
  
  out = vec;
end

if strcmp(to_what,'param')

  for i=1:length(gaparam)
    param.(gaparam(i).name) = p(gaparam(i).vector_index);
  end
  
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
  
  param.lrate_fc_rec = [0 0; 0 0];
  param.lrate_cf_rec = [0 0; 0 0];
  param.eye_cf = 0;

  % sim code needs dt, dt_tau, and sq_dt_tau. Why aren't these
  % calculated as needed?
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

  param.do_end_list = 0;
  
  % change Dakota values into necessary param format
  
  if all(isfield(param,{'B_enc_temp','B_rec_temp','B_source'}))
    param.B_enc = [param.B_enc_temp param.B_source];
    param.B_rec = [param.B_rec_temp param.B_source];
  elseif all(isfield(param,{'B_enc_temp','B_rec_temp',...
                            'B_enc_source','B_rec_source'}))
    param.B_enc = [param.B_enc_temp param.B_enc_source];
    param.B_rec = [param.B_rec_temp param.B_rec_source];
  else
    error('Beta value is missing from param structure.')
  end
    
  if isfield(param,'gamma_fc')
    param.lrate_fc_enc = [param.gamma_fc param.gamma_fc; 0 0];
    param.eye_fc = 1 - param.gamma_fc;
  elseif isfield(param, 'eye_fc')
    param.gamma_fc = 1 - param.eye_fc;
    param.lrate_fc_enc = [param.gamma_fc param.gamma_fc; 0 0];
  else
    error('gamma_fc value is missing from param structure.')
  end
  
  if isfield(param,'task_lrate_cf')
    param.lrate_cf_enc = [1 0; param.task_lrate_cf 0];
  else
    error('Task lrate_cf value is missing from param structure.')
  end
  
  if isfield(param,'d')
    param.shift_schedule = [param.d 0];
  else
    error('d value is missing from param structure.')
  end
  
  % size of the item feature layer
  param.nDim = 40;
  param.nSource = 3;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % DISPLAY AND OPTIMIZATION %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%

  param.visualize_item_recall = 0;
  param.mult_subj = 1;
  % limit the number of output positions
  % param.maxOP = 3;
  param.justControl = 0;
  
  out = param;
  
end


