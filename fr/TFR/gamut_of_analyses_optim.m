function [resvec, semvec, res] = gamut_of_analyses_optim(data, sem_mat)
% [resvec, semvec, res] = gamut_of_analyses_optim(beh_data.full, sem_mat);
%
% [resvec, semvec, res] = gamut_of_analyses_optim(net_data, sem_mat);
%
% Gets the results vectors without frills, for running on the
% cluster. 

% an optimized version of the analyses that attempts to minimize
% processing

res = [];
vecElements = 93;

%%% NET DATA %%%
% if no reaction times, net data
if ~isfield(data,'react_times')
  % clean up data
  % remove any extra padding from end of presentation data
  data.pres_itemnos = data.pres_itemnos(:,1:data.listLength);
  data.pres_task = data.pres_task(:,1:data.listLength);
  data.listType = data.listType(:,1);
  
  % add rec task
  intrusions_mask = make_mask_exclude_intrusions2d(data.recalls);
  data.task = create_rec_labels(data.pres_task, data.recalls, ...
                                intrusions_mask);
  data.task(data.task<0) = -999;
  
  % add dummy react_times
  data.react_time = NaN(size(data.pres_itemnos));
end


%%% PREPARE DATA %%%
co = trial_subset(data.listType==0 | data.listType==1, data);
sh = trial_subset(data.listType==2, data);

data.co = co;
data.sh = sh;
clear co sh

% add useful task fields
data.co = task_info(data.co);
data.sh = task_info(data.sh);

subjs = unique(data.co.subject);
nsubj = length(subjs);

% don't run the analysis if nothing was recalled
if max(max(data.co.recalls)) ~= 0 & max(max(data.sh.recalls)) ~= 0

  fprintf('gamut_optim.\n');
  
  % preparation of the data
  % add fake data
  mult_subj = 5;
  n_trials = max(collect(data.co.subject, unique(data.co.subject)'));
  data = make_fake_subjs(data, mult_subj*n_trials);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % train serial position co and sh %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  res.sh.sp_train.sp_subj = train_spc(data.sh.recalls, data.sh.pres_task, ...
      data.sh.subject, data.sh.listLength);
  res.sh.sp_train.sp = nanmean(res.sh.sp_train.sp_subj);
  
  res.fake.sp_train.sp_subj = train_spc(data.fake.recalls, data.fake.pres_task, ...
      data.fake.subject, data.fake.listLength);
  res.fake.sp_train.sp = nanmean(res.fake.sp_train.sp_subj);
  
  res.sh.sp_train.sem_sp = nanstd(res.sh.sp_train.sp_subj)/sqrt(size(res.sh.sp_train.sp_subj,1)-1);
  res.fake.sp_train.sem_sp = nanstd(res.fake.sp_train.sp_subj)/sqrt(size(res.fake.sp_train.sp_subj,1)-1);
  
  d1 = res.sh.sp_train.sp - res.fake.sp_train.sp;
  sh_length = size(res.sh.sp_train.sp_subj,1);
  fake_length = size(res.fake.sp_train.sp_subj,1);
  
  % Checks for data in simulation that doesn't have trains of length 6 and
  % 7 per session
  if sh_length < fake_length
      res.fake.sp_train.sp_subj = res.fake.sp_train.sp_subj((end-sh_length + 1):end,:);
  end
  if sh_length > fake_length
      res.sh.sp_train.sp_subj = res.sh.sp_train.sp_subj((end-fake_length + 1):end,:);
  end
  s1 = nanstd(res.sh.sp_train.sp_subj-res.fake.sp_train.sp_subj)/...
                  sqrt(nsubj-1);
  
  %%%%%%%%%%%%%%%%%%%%%%%
  % train CRP co and sh %
  %%%%%%%%%%%%%%%%%%%%%%%

  total_sh_crp = train_crp(data.sh.recalls, data.sh.pres_trainno, ...
                           data.sh.subject, data.sh.listLength);
  total_fake_crp = train_crp(data.fake.recalls, data.fake.pres_trainno, ...
                             data.fake.subject, data.fake.listLength);
    
  cut_sh_crp = total_sh_crp(:,2:12);
  cut_fake_crp = total_fake_crp(:,2:12);
                  
  res.sh.crp_train.crp = nanmean(cut_sh_crp,1);
  res.sh.crp_train.sem_crp = nanstd(cut_sh_crp,1)/sqrt(nsubj-1);
                                    
  res.fake.crp_train.crp = nanmean(cut_fake_crp,1);
  res.fake.crp_train.sem_crp = nanstd(cut_fake_crp,1)/sqrt(nsubj-1);
  
  d2 = res.sh.crp_train.crp - res.fake.crp_train.crp;
  
  sh_length = size(cut_sh_crp,1);
  fake_length = size(cut_fake_crp,1);
  
  % Checks for data in simulation that doesn't have trains of length 6 and
  % 7 per session
  if sh_length < fake_length
      cut_fake_crp = cut_fake_crp((end-sh_length + 1):end,:);
  end
  if sh_length > fake_length
      cut_sh_crp = cut_sh_crp((end-fake_length + 1):end,:);
  end
  s2 = nanstd(cut_sh_crp-cut_fake_crp)/sqrt(nsubj-1);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % within / between transition probability %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  sh_subj = length(unique(data.sh.subject));
  sh_mask = make_clean_recalls_mask2d(data.sh.recalls);
  sh_wb = source_fact(data.sh.task,data.sh.subject,sh_mask);
  res.sh.trans_prob.wb = mean(sh_wb);
  res.sh.trans_prob.sem_wb = std(sh_wb) / sqrt(sh_subj - 1);

  fake_subj = length(unique(data.fake.subject));
  fake_mask = make_clean_recalls_mask2d(data.fake.recalls);
  fake_wb = source_fact(data.fake.task,data.fake.subject,fake_mask);
  res.fake.trans_prob.wb = mean(fake_wb);
  res.fake.trans_prob.sem_wb = std(fake_wb) / sqrt(fake_subj - 1);

  sh_train_wb = source_fact_remote(data.sh.pres_task, ...
      data.sh.pres_trainno, data.sh.recalls, data.sh.subject);
  res.sh.trans_prob.train_wb = mean(sh_train_wb);
  res.sh.trans_prob.sem_train_wb = std(sh_train_wb) / sqrt(sh_subj - 1);

  fake_train_wb = source_fact_remote(data.fake.pres_task, ...
      data.fake.pres_trainno, data.fake.recalls, data.fake.subject);
  res.fake.trans_prob.train_wb = mean(fake_train_wb);
  res.fake.trans_prob.sem_train_wb = std(fake_train_wb) / sqrt(fake_subj - 1);
  
  %%%%%%%%%%%%%%%%%
  % lag CRP by OP %
  %%%%%%%%%%%%%%%%%

  op_mask = make_mask_for_outputs(data.recalls, 1:4);
  lowermask = data.recalls >= 5;
  uppermask = data.recalls <= 19;
  mask = op_mask & lowermask & uppermask;
  res.crp.op1_3 = bin_crp(data.recalls, data.subject, ...
      data.listLength, [-19, -17, -5, -1, 1, 2, 6, 18, 20], ...
      mask, op_mask);
  res.crp.op1_3 = res.crp.op1_3(:,1:end-1); % remove NaN from end

  op_mask = make_mask_for_outputs(data.recalls, 4:size(data.recalls,2));
  lowermask = data.recalls >= 5;
  uppermask = data.recalls <= 19;
  mask = op_mask & lowermask & uppermask;
  res.crp.op4on = bin_crp(data.recalls, data.subject, ...
      data.listLength, [-19, -17, -5, -1, 1, 2, 6, 18, 20], ...
      mask, op_mask);
  res.crp.op4on = res.crp.op4on(:,1:end-1); % remove NaN from end
  
  res.crp.mean1_3 = nanmean(res.crp.op1_3);
  res.crp.mean4on = nanmean(res.crp.op4on);
  
  nSubjByBin_OP13 = sum(~isnan(res.crp.op1_3));
  nSubjByBin_OP4on = sum(~isnan(res.crp.op4on));
  
  res.crp.sem_crp1_3 = nanstd(res.crp.op1_3)./sqrt(nSubjByBin_OP13-1);
  res.crp.sem_crp4on = nanstd(res.crp.op4on)./sqrt(nSubjByBin_OP4on-1);  
  

  %%%%%%%%%%%%%%%%%%%%%
  % PR for last 3 SPs %
  %%%%%%%%%%%%%%%%%%%%%
  
  mask = make_mask_for_outputs(data.co.recalls, 1);
  res.spc.pfr.sp_bysubj = cond_spc(data.co.recalls, data.co.subject, ...
      data.co.listLength, mask);
  res.spc.pfr.sp = nanmean(res.spc.pfr.sp_bysubj);

  rec_mask = make_mask_for_outputs(data.co.recalls, 2);
  priors = make_mask_for_outputs(data.co.recalls, 1);
  res.spc.psr.sp_bysubj = cond_spc(data.co.recalls, data.co.subject, ...
      data.co.listLength, rec_mask, priors);
  res.spc.psr.sp = nanmean(res.spc.psr.sp_bysubj);

  rec_mask2 = make_mask_for_outputs(data.co.recalls, 3);
  priors2 = make_mask_for_outputs(data.co.recalls, 1:2);
  res.spc.ptr.sp_bysubj = cond_spc(data.co.recalls, data.co.subject, ...
      data.co.listLength, rec_mask2, priors2);
  res.spc.ptr.sp = nanmean(res.spc.ptr.sp_bysubj);

  %%%%%%%%%%%%%%
  % IRTs by OP %
  %%%%%%%%%%%%%%
  
  % time to first recall (OP 0)
  mean_times = apply_by_index(@nanmean, data.co.subject, 1, ...
                              {data.co.times});

  % IRTS
  % since control, find task_sim covers all valid irts
  irts = shift_cost(data.co.recalls, data.co.times, ...
      data.co.rec_itemnos, data.co.task, data.co.subject, sem_mat);
  
  % first 9 (from) OPs
  nOP = 9;
  maxop = max(sum(make_clean_recalls_mask2d(data.co.recalls), 2));
  op_ind = min(maxop - 1, nOP);
  sub_irts = irts.task_sim(:,1:op_ind);
  
  % add padding if necessary
  op_diff = nOP - size(sub_irts, 2);
  if op_diff > 0
    sub_irts = [sub_irts NaN(size(sub_irts, 1), op_diff)];
  end

  % time to first recall and IRTs up to OP 9
  res.irt.irts = [mean_times(:,1) sub_irts];
  res.irt.mean_irt = nanmean(res.irt.irts,1);
  res.irt.sem_irt = nanstd(res.irt.irts)./sqrt(nsubj-1);

  %%%%%%%%%%%%%%%%%%%%%%%
  % Recall shift costs  %
  %%%%%%%%%%%%%%%%%%%%%%%

  %irts = shift_cost(data.co.recalls, data.co.times, ...
  %    data.co.rec_itemnos, data.co.task, data.co.subject, sem_mat);
  %mask = make_mask_for_outputs(data.sh.recalls, 1:9);
  %source = shift_cost(data.sh.recalls, data.sh.times, ...
  %    data.sh.rec_itemnos, data.sh.task, data.sh.subject, ...
  %    sem_mat, mask);
  %
  %shift_ls = nanmean(irts.sem_diff);
  %shift_hs = nanmean(irts.sem_sim);
  %sem_subj = nanmean(irts.sem_diff - irts.sem_sim, 2);
  %res.shift.mean_sem_ls = nanmean(shift_ls);
  %res.shift.mean_sem_hs = nanmean(shift_hs);
  %res.shift.mean_sem = nanmean(sem_subj);
  %res.shift.sem_sem_ls = nanstd(shift_ls)/sqrt(nsubj-1);
  %res.shift.sem_sem_hs = nanstd(shift_hs)/sqrt(nsubj-1);
  %res.shift.sem_sem = nanstd(sem_subj)/sqrt(nsubj-1);
  %
  %shift_fl = nanmean(irts.lag_diff);
  %shift_nl = nanmean(irts.lag_sim);
  %lag_subj = nanmean(irts.lag_diff - irts.lag_sim, 2);
  %res.shift.mean_lag_fl = nanmean(shift_fl);
  %res.shift.mean_lag_nl = nanmean(shift_nl);
  %res.shift.mean_lag = nanmean(lag_subj);
  %res.shift.sem_lag_fl = nanstd(shift_fl)/sqrt(nsubj-1);
  %res.shift.sem_lag_nl = nanstd(shift_nl)/sqrt(nsubj-1);
  %res.shift.sem_lag = nanstd(lag_subj)/sqrt(nsubj-1);
  %
  %shift_sh = nanmean(source.task_diff);
  %shift_rp = nanmean(source.task_sim);
  %task_subj = nanmean(source.task_diff - source.task_sim, 2);
  %res.shift.mean_source_sh = nanmean(shift_sh);
  %res.shift.mean_source_rp = nanmean(shift_rp);
  %res.shift.mean_source = nanmean(task_subj);
  %res.shift.sem_source_sh = nanstd(shift_sh)/sqrt(nsubj-1);
  %res.shift.sem_source_rp = nanstd(shift_rp)/sqrt(nsubj-1);
  %res.shift.sem_source = nanstd(task_subj)/sqrt(nsubj-1);
  %
  %res.shift.shift_task = [res.shift.mean_sem_ls res.shift.mean_lag_fl ...
  %    res.shift.mean_source_sh];
  %res.shift.shift_task_sem = [res.shift.sem_sem_ls res.shift.sem_lag_fl ...
  %    res.shift.sem_source_sh];
  %res.shift.control = [res.shift.mean_sem_hs res.shift.mean_lag_nl ...
  %    res.shift.mean_source_rp];
  %res.shift.control_sem = [res.shift.sem_sem_hs res.shift.sem_lag_nl ...
  %    res.shift.sem_source_rp];
  %res.shift.diff = [res.shift.mean_sem res.shift.mean_lag ...
  %    res.shift.mean_source];
  %res.shift.diff_sem = [res.shift.sem_sem res.shift.sem_lag ...
  %    res.shift.sem_source];  

  
  
  % create the data vector to output
  % fake train serial position   - 7 elements
  % shift train serial position  - 7 elements
  % fake train crp (-5:+5)       - 11 elements
  % shift train crp (-5:+5)      - 11 elements
  % fake within prob all trans   - 1 element
  % shift within prob all trans  - 1 element
  % fake within prob train       - 1 element
  % shift within prob train      - 1 element
  % diff btwn fake and shift train spc - 7 elements
  % diff btwn fake and shift train crp - 11 elements
  % co crp 8 bins first 3 OPs    - 8 elements
  % co crp 8 bins rest of OPs    - 8 elements
  % pfr control final 3 sp       - 3 elements
  % psr control final 3 sp       - 3 elements
  % ptr control final 3 sp       - 3 elements
  % mean irts 0 through 9        - 10 elements
  
  %% Shift costs - control        - 3 elements
  %% Shift costs - shift          - 3 elements
  %% Shift costs - diff           - 3 elements
  
  resvec = zeros(1,vecElements);
  semvec = zeros(1,vecElements);
  
  resvec(1:7)   = res.fake.sp_train.sp;
  semvec(1:7)   = res.fake.sp_train.sem_sp;

  resvec(8:14)  = res.sh.sp_train.sp;
  semvec(8:14)  = res.sh.sp_train.sem_sp;
  
  resvec(15:25) = res.fake.crp_train.crp;
  semvec(15:25) = res.fake.crp_train.sem_crp;
  
  resvec(26:36) = res.sh.crp_train.crp;
  semvec(26:36) = res.sh.crp_train.sem_crp;
  
  resvec(37)    = res.fake.trans_prob.wb;
  semvec(37)    = res.fake.trans_prob.sem_wb;
  
  resvec(38)    = res.sh.trans_prob.wb;
  semvec(38)    = res.sh.trans_prob.sem_wb;
  
  resvec(39)    = res.fake.trans_prob.train_wb;
  semvec(39)    = res.fake.trans_prob.sem_train_wb;
  
  resvec(40)    = res.sh.trans_prob.train_wb;
  semvec(40)    = res.sh.trans_prob.sem_train_wb;
  
  resvec(41:47) = d1;
  semvec(41:47) = s1;
  
  resvec(48:58) = d2;
  semvec(48:58) = s2;
    
  resvec(59:66) = res.crp.mean1_3;
  semvec(59:66) = res.crp.sem_crp1_3;
  
  resvec(67:74) = res.crp.mean4on;
  semvec(67:74) = res.crp.sem_crp4on;
  
  resvec(75:77) = res.spc.pfr.sp(end-2:end);
  semvec(75:77) = nanstd(res.spc.pfr.sp_bysubj(:,end-2:end))/sqrt(nsubj-1);

  resvec(78:80) = res.spc.psr.sp(end-2:end);
  semvec(78:80) = nanstd(res.spc.psr.sp_bysubj(:,end-2:end))/sqrt(nsubj-1);

  resvec(81:83) = res.spc.ptr.sp(end-2:end);
  semvec(81:83) = nanstd(res.spc.ptr.sp_bysubj(:,end-2:end))/sqrt(nsubj-1);

  resvec(84:93) = res.irt.mean_irt;
  semvec(84:93) = res.irt.sem_irt;
  
  %resvec(94:96) = res.shift.shift_task;
  %semvec(94:96) = res.shift.shift_task_sem;
  %resvec(97:99) = res.shift.control;
  %semvec(97:99) = res.shift.control_sem;
  %resvec(100:102) = res.shift.diff;
  %semvec(100:102) = res.shift.diff_sem; 

else 
  resvec(1:vecElements) = NaN;
  semvec(1:vecElements) = NaN;
end




