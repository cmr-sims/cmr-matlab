function [fit] = ga_report(histfile,titlebase,setrange) 
% [fit] = ga_report(histfile,titlebase,setrange) 
%
% script to check the many results dumped out by the GA
%
% [fit] = ga_report('ga_taskFR_101607a.txt','101607a',[1:10]);



h = loadSearchHist(histfile);
%titlebase;

datapath = '/Users/polyn/SCIENCE/EXPERIMENTS/apem_e7/results';

% pick the parameter sets to inspect
[fval fidx] = sort(h.f);

% create the fit structure
fit.param = h.param(fidx(setrange),:);
fit.f = fval(setrange);
fit.respath = '/Users/polyn/SCIENCE/SIMULATION/optim_ga_cmr/gafigs';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENERATE THE FIGURES FOR THE REAL DATA %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% iterate through the parameter sets with runParamVec
for i = 1:length(setrange)
  
  param = convert_param_CMR2GA(fit.param(i,:),'param');
  param.semPath = '/Users/polyn/SCIENCE/SIMULATION/CMR_sims/LSA_tfr.mat';
  [data,net] = prepare_taskFR(param,datapath);
  
  % [data,res,net,param] = runParamVec(fit.param(i,:),@tcm_exptSim_taskFR,fit.respath);
  % generate the figures and print to disk
  % add the path for each figure to fit.fig{}.path

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % GENERATE THE TRANSITION PROBABILITIES %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  subjects = unique(data.net.sh.subject);
  no_subjs = length(subjects);

  LL = data.net.co.listLength;

  tvec.co = transit_TFR(data.net.co);
  tvec.sh = transit_TFR(data.net.sh);
  tvec.fake = transit_TFR(data.net.fake);

  % calculation of transition probabilities
  tProb.fake = taskTrans(data.net.fake,tvec.fake,0);
  tProb.sh = taskTrans(data.net.sh,tvec.sh,0);
  % shift cond task transits
  fit.wb(i,1) = tProb.sh.wb(1);
  % relab cond task transits
  fit.wb(i,2) = tProb.fake.wb(1);
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%
  % GENERATE THE TRAIN SPC %
  %%%%%%%%%%%%%%%%%%%%%%%%%%
  f = sfigure(1);
  clf;

  [res.fake.spc_train] = spc_train(data.net.fake);
  [res.sh.spc_train] = spc_train(data.net.sh);
  
  x = 1:length(res.fake.spc_train.sp);
  p = errorbar(x,res.fake.spc_train.sp,res.fake.spc_train.sem_sp,'ko-','MarkerSize',10);
  hold on;
  p = errorbar(x,res.sh.spc_train.sp,res.sh.spc_train.sem_sp,'k^-','MarkerSize',10);
  axis([x(1)-0.5 x(end)+0.5 0.2 0.9])
  % set(p,'LineWidth',1.5);
  xlabel('Train serial position');
  ylabel('Prop. recalled');
  
  legend('Relab. Control','Shift','Location','NorthWest');
  publishFig;
  fit.fig{1}.path{i} = fullfile(fit.respath,strcat('f1p',num2str(i)));
  print('-depsc',fit.fig{1}.path{i});

  %%%%%%%%%%%%%%%%%%%%%%%%%%
  % GENERATE THE TRAIN CRP %
  %%%%%%%%%%%%%%%%%%%%%%%%%%
  sfigure(1);
  clf;
  
  res.co.CRP = calc_crp(data.net.co,tvec.co,0);
  res.sh.CRP = calc_crp(data.net.sh,tvec.sh,0);
  res.fake.CRP = calc_crp(data.net.fake,tvec.fake,0);
  
  MNT = length(unique(data.net.sh.pres_trainno));

  mx_lag = 5;
  a(1) = axes('position',[.15 .45 .8 .5]);
  hold on;
  crp_plot_train(res.fake.CRP.by_train, MNT, mx_lag, 'ko-');
  crp_plot_train(res.sh.CRP.by_train, MNT, mx_lag, 'k^-');
  ylabel('Cond. Resp. Prob.');
  % grid on; 
  box on;
  
  legend('Relab. control','Shift','Location','NorthWest');

  % compare transition probabilities between the control and shift
  % conditions. 
  [h,p,ci,stats] = ttest(res.sh.CRP.by_train(:,MNT-mx_lag:MNT+mx_lag),res.fake.CRP.by_train(:,MNT-mx_lag:MNT+mx_lag));
  plot_h = double(p<0.05);
  plot_h(plot_h==0)=-999;
  plot_h(plot_h==1)=0.1;
  
  res.stats.CRP.by_train.h = h;
  res.stats.CRP.by_train.p = p;
  res.stats.CRP.by_train.ci = ci;
  res.stats.CRP.by_train.stats = stats;
  
  % plot the difference between the control and shift probabilities
  a(2) = axes('position',[.15 .1 .8 .18]);
  % grid on; 
  box on;
  train_fake = nanmean(res.fake.CRP.by_train);
  train_sh = nanmean(res.sh.CRP.by_train);
  diff_by_subj = res.sh.CRP.by_train - res.fake.CRP.by_train;
  sem_train = nanstd(diff_by_subj)/sqrt(no_subjs-1);
  sem_train = sem_train(MNT-mx_lag:MNT+mx_lag);
  x = -mx_lag:mx_lag;
  diff_train = train_sh-train_fake;
  diff_train = diff_train(MNT-mx_lag:MNT+mx_lag);
  p = errorbar(x(1:2:end),diff_train(1:2:end),sem_train(1:2:end),'.k--');
  %set(p,'LineWidth',2);
  hold on;
  p = errorbar(x(2:2:end),diff_train(2:2:end),sem_train(2:2:end),'.k-');
  %set(p,'LineWidth',2);
  axis([-mx_lag-1 mx_lag+1 -0.08 0.12]);
  p = plot(x,plot_h,'ko');
  set(p,'LineWidth',1.5,'MarkerSize',10);
  ylabel('Diff.');
  % grid on;
  plot([-mx_lag-1 mx_lag+1],[0 0],'k:','LineWidth',1.5);
  box on;
  publishFig;
  
  fit.fig{2}.path{i} = fullfile(fit.respath,strcat('f2p',num2str(i)));
  print('-depsc',fit.fig{2}.path{i});

  
  
end


model_report(fit,titlebase,fit.respath);

