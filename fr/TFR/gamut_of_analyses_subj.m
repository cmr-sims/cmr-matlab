function [resvec,semvec,res] = gamut_of_analyses_subj(data, sem_mat)
% [resvec,semvec,res] = gamut_of_analyses_subj(data, sem_mat);
%
% Gets the results vectors without frills, for running on the
% cluster. 
%

res = [];
vecElements = 104;
subjs = unique(data.co.session);
nsubj = length(subjs);

% don't run the analysis if nothing was recalled
if max(max(data.co.recalls)) ~= 0 && max(max(data.sh.recalls)) ~= 0

  fprintf('gamut_subj.\n');  
    
  % serial position co and sh

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % train serial position co and sh %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  res.sp_train.sh.sp_subj = train_spc(data.sh.recalls, data.sh.pres_task, ...
      data.sh.session, data.sh.listLength);
  res.sp_train.sh.sp = nanmean(res.sp_train.sh.sp_subj);
  
  res.sp_train.fake.sp_subj = train_spc(data.fake.recalls, data.fake.pres_task, ...
      data.fake.session, data.fake.listLength);
    res.sp_train.fake.sp = nanmean(res.sp_train.fake.sp_subj);
  
  res.sp_train.sh.sem_sp = nanstd(res.sp_train.sh.sp_subj)/sqrt(size(res.sp_train.sh.sp_subj,1)-1);
  res.sp_train.fake.sem_sp = nanstd(res.sp_train.fake.sp_subj)/sqrt(size(res.sp_train.fake.sp_subj,1)-1);
  
  d1 = res.sp_train.sh.sp - res.sp_train.fake.sp;
  sh_length = size(res.sp_train.sh.sp_subj,1);
  fake_length = size(res.sp_train.fake.sp_subj,1);
  
  % Checks for data in simulation that doesn't have trains of length 6 and
  % 7 per session
  if sh_length < fake_length
      res.sp_train.fake.sp_subj = res.sp_train.fake.sp_subj((end-sh_length + 1):end,:);
  end
  if sh_length > fake_length
      res.sp_train.sh.sp_subj = res.sp_train.sh.sp_subj((end-fake_length + 1):end,:);
  end
  s1 = nanstd(res.sp_train.sh.sp_subj-res.sp_train.fake.sp_subj)/...
                  sqrt(nsubj-1);
                          
  %%%%%%%%%%%%%%%%%%%%%
  % PR for last 3 SPs %
  %%%%%%%%%%%%%%%%%%%%%
  
  mask = make_mask_for_outputs(data.co.recalls, 1);
  res.spc.pfr.sp_bysubj = cond_spc(data.co.recalls, data.co.session, ...
      data.co.listLength, mask);
  res.spc.pfr.sp = nanmean(res.spc.pfr.sp_bysubj);

  rec_mask = make_mask_for_outputs(data.co.recalls, 2);
  priors = make_mask_for_outputs(data.co.recalls, 1);
  res.spc.psr.sp_bysubj = cond_spc(data.co.recalls, data.co.session, ...
      data.co.listLength, rec_mask, priors);
  res.spc.psr.sp = nanmean(res.spc.psr.sp_bysubj);

  rec_mask2 = make_mask_for_outputs(data.co.recalls, 3);
  priors2 = make_mask_for_outputs(data.co.recalls, 1:2);
  res.spc.ptr.sp_bysubj = cond_spc(data.co.recalls, data.co.session, ...
      data.co.listLength, rec_mask2, priors2);
  res.spc.ptr.sp = nanmean(res.spc.ptr.sp_bysubj);            
              
  %%%%%%%%%%%%%%%%%%%%%%%
  % train CRP co and sh %
  %%%%%%%%%%%%%%%%%%%%%%%

  total_sh_crp = train_crp(data.sh.recalls, data.sh.train, ...
      data.sh.pres_trainno, data.sh.pres_trainlen, ...
      data.sh.session, data.sh.listLength);
  total_fake_crp = train_crp(data.fake.recalls, data.fake.train, ...
      data.fake.pres_trainno, data.fake.pres_trainlen, ...
      data.fake.session, data.fake.listLength);
                                    
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
  
  %%%%%%%%%%%%%%%%%
  % lag CRP by OP %
  %%%%%%%%%%%%%%%%%

  op_mask = make_mask_for_outputs(data.full.recalls, 1:4);
  lowermask = data.full.recalls >= 5;
  uppermask = data.full.recalls <= 19;
  mask = op_mask & lowermask & uppermask;
  res.crp.op1_2 = bin_crp(data.full.recalls, data.full.session, ...
      data.full.listLength, [-19, -17, -5, -1, 1, 2, 6, 18, 20], mask);

  op_mask = make_mask_for_outputs(data.full.recalls, 4:size(data.full.recalls,2));
  lowermask = data.full.recalls >= 5;
  uppermask = data.full.recalls <= 19;
  mask = op_mask & lowermask & uppermask;
  res.crp.op4on = bin_crp(data.full.recalls, data.full.session, ...
  data.full.listLength, [-19, -17, -5, -1, 1, 2, 6, 18, 20], mask);
  
  res.crp.mean1_2 = nanmean(res.crp.op1_2);
  res.crp.mean4on = nanmean(res.crp.op4on);
  
  nSubjByBin_OP12 = sum(~isnan(res.crp.op1_2));
  nSubjByBin_OP4on = sum(~isnan(res.crp.op4on));
  
  res.crp.sem_crp1_2 = nanstd(res.crp.op1_2)./sqrt(nSubjByBin_OP12-1);
  res.crp.sem_crp4on = nanstd(res.crp.op1_2)./sqrt(nSubjByBin_OP4on-1);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % within / between transition probability %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  sh_subj = length(unique(data.sh.session));
  sh_mask = make_clean_recalls_mask2d(data.sh.recalls);
  sh_wb = source_fact(data.sh.task,data.sh.session,sh_mask);
  res.trans_prob.sh.wb = mean(sh_wb);
  res.trans_prob.sh.sem_wb = std(sh_wb) / sqrt(sh_subj - 1);

  fake_mask = make_clean_recalls_mask2d(data.fake.recalls);
  fake_wb = source_fact(data.fake.task,data.fake.session,fake_mask);
  res.trans_prob.fake.wb = mean(fake_wb);
  res.trans_prob.fake.sem_wb = res.trans_prob.sh.sem_wb;

  sh_train_wb = source_fact_remote(data.sh.pres_task, ...
      data.sh.pres_trainno, data.sh.recalls, data.sh.session);
  res.trans_prob.sh.train_wb = mean(sh_train_wb);
  res.trans_prob.sh.sem_train_wb = std(sh_train_wb) / sqrt(sh_subj - 1);

  fake_train_wb = source_fact_remote(data.fake.pres_task, ...
      data.fake.pres_trainno, data.fake.recalls, data.fake.session);
  res.trans_prob.fake.train_wb = mean(fake_train_wb);
  res.trans_prob.fake.sem_train_wb = res.trans_prob.sh.sem_train_wb;

  %%%%%%%%%%%%%%%%%%%%%%%
  % Recall shift costs  %
  %%%%%%%%%%%%%%%%%%%%%%%

  irts = shift_cost(data.co.recalls, data.co.times, ...
      data.co.rec_itemnos, data.co.task, data.co.session, sem_mat);
  mask = make_mask_for_outputs(data.sh.recalls, 1:9);
  source = shift_cost(data.sh.recalls, data.sh.times, ...
      data.sh.rec_itemnos, data.sh.task, data.sh.session, ...
      sem_mat, mask);
  
  shift_ls = nanmean(irts.sem_diff);
  shift_hs = nanmean(irts.sem_sim);
  sem_subj = nanmean(irts.sem_diff - irts.sem_sim, 2);
  res.shift.mean_sem_ls = nanmean(shift_ls);
  res.shift.mean_sem_hs = nanmean(shift_hs);
  res.shift.mean_sem = nanmean(sem_subj);
  res.shift.sem_sem_ls = nanstd(shift_ls)/sqrt(nsubj-1);
  res.shift.sem_sem_hs = nanstd(shift_hs)/sqrt(nsubj-1);
  res.shift.sem_sem = nanstd(sem_subj)/sqrt(nsubj-1);

  shift_fl = nanmean(irts.lag_diff);
  shift_nl = nanmean(irts.lag_sim);
  lag_subj = nanmean(irts.lag_diff - irts.lag_sim, 2);
  res.shift.mean_lag_fl = nanmean(shift_fl);
  res.shift.mean_lag_nl = nanmean(shift_nl);
  res.shift.mean_lag = nanmean(lag_subj);
  res.shift.sem_lag_fl = nanstd(shift_fl)/sqrt(nsubj-1);
  res.shift.sem_lag_nl = nanstd(shift_nl)/sqrt(nsubj-1);
  res.shift.sem_lag = nanstd(lag_subj)/sqrt(nsubj-1);

  shift_sh = nanmean(source.task_diff);
  shift_rp = nanmean(source.task_sim);
  task_subj = nanmean(source.task_diff - source.task_sim, 2);
  res.shift.mean_source_sh = nanmean(shift_sh);
  res.shift.mean_source_rp = nanmean(shift_rp);
  res.shift.mean_source = nanmean(task_subj);
  res.shift.sem_source_sh = nanstd(shift_sh)/sqrt(nsubj-1);
  res.shift.sem_source_rp = nanstd(shift_rp)/sqrt(nsubj-1);
  res.shift.sem_source = nanstd(task_subj)/sqrt(nsubj-1);

  res.shift.shift_task = [res.shift.mean_sem_ls res.shift.mean_lag_fl ...
      res.shift.mean_source_sh];
  res.shift.shift_task_sem = [res.shift.sem_sem_ls res.shift.sem_lag_fl ...
      res.shift.sem_source_sh];
  res.shift.control = [res.shift.mean_sem_hs res.shift.mean_lag_nl ...
      res.shift.mean_source_rp];
  res.shift.control_sem = [res.shift.sem_sem_hs res.shift.sem_lag_nl ...
      res.shift.sem_source_rp];
  res.shift.diff = [res.shift.mean_sem res.shift.mean_lag ...
      res.shift.mean_source];
  res.shift.diff_sem = [res.shift.sem_sem res.shift.sem_lag ...
      res.shift.sem_source];
  
  
  %%%%%%%%%%%%%%%
  % CRL by O.P  %
  %%%%%%%%%%%%%%%

  crl_op = {};
  count = 0;

  for cols = 1:3:6
      count = count+1;
      ops = cols:cols+3;
      crl_all = crl2(data.co.recalls, data.co.times, ...
          data.co.session, data.co.session, data.co.listLength, ops);
    
      bin_crl(:,1) = nanmean(crl_all(:,19:21),2);
      bin_crl(:,2:6) = crl_all(:,22:26);
      bin_crl(:,7) = nanmean(crl_all(:,27:29),2);
    
      mu = nanmean(bin_crl);
      sigma = nanstd(bin_crl);
      n = size(bin_crl, 1);
      Meanmat = repmat(mu,n,1);
      Sigmamat = repmat(sigma,n,1);
      outliers = abs(bin_crl-Meanmat) > 3*Sigmamat;
      [row,col] = find(outliers);
      bin_crl_mod = ~outliers .* bin_crl;
      for i = 1:length(row)
          bin_crl_mod(row(i),col(i)) = NaN;
      end
    
      crl_op{count} = bin_crl_mod;
  end
  
  res.crl_op.mean_first3 = nanmean(crl_op{1});
  res.crl_op.mean_next3 = nanmean(crl_op{2});
  res.crl_op.sem_first3 = nanstd(crl_op{1})/sqrt(nsubj-1);
  res.crl_op.sem_next3 = nanstd(crl_op{2})/sqrt(nsubj-1);
   

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
  % Shift costs - control        - 3 elements
  % Shift costs - shift          - 3 elements
  % Shift costs - diff           - 3 elements
  % CRL by O.P.                  - 12 elements
  
  resvec = zeros(1,vecElements);
  semvec = zeros(1,vecElements);
  
  resvec(1:7)   = res.sp_train.fake.sp;
  semvec(1:7)   = res.sp_train.fake.sem_sp;

  resvec(8:14)  = res.sp_train.sh.sp;
  semvec(8:14)  = res.sp_train.sh.sem_sp;
  
  resvec(15:25) = res.fake.crp_train.crp;
  semvec(15:25) = res.fake.crp_train.sem_crp;
  
  resvec(26:36) = res.sh.crp_train.crp;
  semvec(26:36) = res.sh.crp_train.sem_crp;
  
  resvec(37)    = res.trans_prob.fake.wb;
  semvec(37)    = res.trans_prob.fake.sem_wb;
  
  resvec(38)    = res.trans_prob.sh.wb;
  semvec(38)    = res.trans_prob.sh.sem_wb;
  
  resvec(39)    = res.trans_prob.fake.train_wb;
  semvec(39)    = res.trans_prob.fake.sem_train_wb;
  
  resvec(40)    = res.trans_prob.sh.train_wb;
  semvec(40)    = res.trans_prob.sh.sem_train_wb;
              
  resvec(41:47) = d1;
  semvec(41:47) = s1;
  
  resvec(48:58) = d2;
  semvec(48:58) = s2;
    
  resvec(59:66) = res.crp.mean1_2(1:end-1);
  semvec(59:66) = res.crp.sem_crp1_2(1:end-1);
  
  resvec(67:74) = res.crp.mean4on(1:end-1);
  semvec(67:74) = res.crp.sem_crp4on(1:end-1);
  
  resvec(75:77) = res.spc.pfr.sp(end-2:end);
  semvec(75:77) = nanstd(res.spc.pfr.sp_bysubj(:,end-2:end))/sqrt(nsubj-1);
  
  resvec(78:80) = res.spc.psr.sp(end-2:end);
  semvec(78:80) = nanstd(res.spc.psr.sp_bysubj(:,end-2:end))/sqrt(nsubj-1);

  resvec(81:83) = res.spc.ptr.sp(end-2:end);
  semvec(81:83) = nanstd(res.spc.ptr.sp_bysubj(:,end-2:end))/sqrt(nsubj-1);
  
  resvec(84:86) = res.shift.shift_task;
  semvec(84:86) = res.shift.shift_task_sem;
  resvec(87:89) = res.shift.control;
  semvec(87:89) = res.shift.control_sem;
  resvec(90:92) = res.shift.diff;
  semvec(90:92) = res.shift.diff_sem; 
  
  resvec(93:98) = [res.crl_op.mean_first3(1:3) res.crl_op.mean_first3(5:7)];
  semvec(93:98) = [res.crl_op.sem_first3(1:3) res.crl_op.sem_first3(5:7)];
  resvec(99:104) = [res.crl_op.mean_next3(1:3) res.crl_op.sem_first3(5:7)];
  semvec(99:104) = [res.crl_op.sem_next3(1:3) res.crl_op.sem_next3(5:7)];
  
else 
  resvec(1:vecElements) = NaN;
  semvec(1:vecElements) = NaN;
end