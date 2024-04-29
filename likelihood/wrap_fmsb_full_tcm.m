
% behavioral data
data_file = '~/matlab/cmr_trunk/fr/TFRLTP/tfrltp_data_sem_co_clean.mat';
data = getfield(load(data_file, 'data'), 'data');

out_file = '/Users/morton/matlab/cmr_trunk/likelihood/bugs/data/full_tcm_data_vec_indiv_1subj.txt';
write_bugs_full_tcm(data, out_file, 1);
return

%data = trial_subset(data.subject == 1, data);

param = struct;
param.B_enc = 0.775;
param.B_rec = 0.815;
param.C = 0.87;
param.T = 10;
param.G = 0.725;
param.P = 0;
%param.X1 = 0.01;
param.X1 = 0.001;
param.X2 = 0.1925;
param.stop_rule = 'ratio';
param = check_param_tcm(param);

seq = gen_tcm(param, data, 1);

[logl, logl_all] = tcm_general(param, data);


crps = logl_crp_serialpos(logl_all, data.recalls);

return

%names = {'B' 'C' 'P' 'G' 'T' 'X'};
%ranges = [0 1; 0 1; 0 10; 0 1; 0 100; 0 10];
%start_param = [.9 .1 1.36 0.578 10 0.071];
%names = {'B' 'C' 'P' 'G' 'T' 'X'};
%ranges = [0 1; 0 1; 0 10; 0 1; 0 100; 0 10];
%start_param = [.9 .1 1.36 0.578 10 0.071];

[param_info, fixed] = search_param_tcm('tcm_stop');
fixed.stop_rule = 'ratio';
%param_info = make_param_info(names, 'range', ranges, 'start', start_param');

fstruct = fixed;
fstruct.data = data;
fstruct.param_info = param_info;
fstruct.f_logl = @tcm_general;

% evaluation function
f = @(x) eval_param_tcm(x, fstruct);

% run parameter search
options = optimset('Display', 'iter');
start_param = [param_info.start];
start_param(end) = 3;
ranges = cat(1, param_info.range);

tic
[best_param, fval, exitflag, output] = fminsearchbnd(f, start_param, ...
                                                     ranges(:,1), ...
                                                     ranges(:,2), options);
toc

% P(stop|OP)
% logl: 30765
%
% P(stop|ratio)
% logl: 30506

[err, logl, logl_all] = eval_param_tcm(best_param, fstruct);
param = unpack_param(best_param, param_info);
param = merge_structs(param, fixed);
param = check_param_tcm(param);

seq = gen_tcm(param, data, 1);

% return
% % write out model information for BUGS
% load('/Users/morton/results/tfrltp/cmr/tcm_lc_2p_1b_c/fmsb1.mat')
% param = unpack_param(parameters, param_info);
% param = check_param_tcm(param);

% out_file = '/Users/morton/matlab/cmr/likelihood/bugs/recency_tcm_data.txt';
% write_recency_bugs_tcm(data, param, out_file);

cond_logl = logl_crp_serialpos(logl_all, data.recalls);

figure(2)
clf
plot_fr_summary(seq, ones(size(seq, 1), 1), data.listLength);

% figure(5)
% clf
% plot_crp_serialpos(cond_logl);
% set(gca, 'YLim', [0 1], 'YTick', 0:.2:1)

% figure(6)
% clf
% plot_crp(crp(seq, ones(size(seq, 1), 1), data.listLength));
% set(gca, 'YLim', [.04 .12], 'YTick', .04:.02:.12)

% figure(7)
% clf
% plot_spc(spc(seq, ones(size(seq, 1), 1), data.listLength));

% figure(8)
% clf
% p_stops = p_stop_op(seq, [], [], [], ones(size(seq, 1), 1));
% plot(1:length(p_stops), p_stops, '-ok', 'LineWidth', 3)
% set(gca, 'XLim', [0 20])
% xlabel('Output Position')
% ylabel('Stop Probability')
% set_fig_style(gcf, 'minimal')

if false
  figure(1)
  clf
  plot_fr_summary(data.recalls, data.subject, data.listLength);
  
  figure(1)
  clf
  crps = crp_serialpos(data.recalls, data.subject, data.listLength);
  plot_crp_serialpos(nanmean(crps, 3));
  set(gca, 'YLim', [0 1], 'YTick', 0:.2:1)
  
  figure(2)
  clf
  plot_crp(crp(data.recalls, data.subject, data.listLength));
  
  figure(3)
  clf
  plot_spc(spc(data.recalls, data.subject, data.listLength));
  
  figure(4)
  clf
  p_stops = p_stop_op(data.recalls, [], [], [], data.subject);
  plot(1:17, p_stops(1:17), '-ok', 'LineWidth', 3)
  xlabel('Output Position')
  ylabel('Stop Probability')
  set_fig_style(gcf, 'minimal')
end


