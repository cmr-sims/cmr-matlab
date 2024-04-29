
res_dir = '~/results/tfrltp/cmr/tcm_lc_simple_was2';
res_name = 'tcm_lc_b2_p2_g_x2_t_was2_fmsb1';

data_file = 'tfrltp_data_sem_co_clean.mat';
load(data_file)

res_file = fullfile(res_dir, [res_name '.mat']);
load(res_file)

param = unpack_param(parameters, param_info);
param.sem_path = 'tfrltp_was.mat';
param = check_param_tcm(param);
seq = gen_tcm(param, data, 10);

close all

figure(1)
subject_model = ones(size(seq, 1), 1);
plot_spc(spc(seq, subject_model, data.listLength));
set_fig_style(gcf, 'minimal')
print(gcf, '-depsc', fullfile(res_dir, res_name, 'spc_model'))

figure(2)
plot_spc(spc(data.recalls, data.subject, data.listLength));
set_fig_style(gcf, 'minimal')
print(gcf, '-depsc', fullfile(res_dir, res_name, 'spc_data'))

figure(3)
plot_spc(pfr(seq, subject_model, data.listLength));
set_fig_style(gcf, 'minimal')
print(gcf, '-depsc', fullfile(res_dir, res_name, 'pfr_model'))

figure(4)
plot_spc(pfr(data.recalls, data.subject, data.listLength));
set_fig_style(gcf, 'minimal')
print(gcf, '-depsc', fullfile(res_dir, res_name, 'pfr_data'))

figure(5)
plot_crp(crp(seq, subject_model, data.listLength));
set_fig_style(gcf, 'minimal')
set(gca, 'YLim', [0 .3], 'YTick', 0:.1:.3)
print(gcf, '-depsc', fullfile(res_dir, res_name, 'crp_model'))

figure(6)
plot_crp(crp(data.recalls, data.subject, data.listLength));
set_fig_style(gcf, 'minimal')
set(gca, 'YLim', [0 .3], 'YTick', 0:.1:.3)
print(gcf, '-depsc', fullfile(res_dir, res_name, 'crp_data'))

figure(7)
plot_crp_serialpos(crp_serialpos(seq, subject_model, data.listLength));
set_fig_style(gcf, 'minimal')
set(gca, 'XTick', [1:2:24], 'YLim', [0 .7], 'YTick', 0:.1:.7)
print(gcf, '-depsc', fullfile(res_dir, res_name, 'crp_serialpos_model'))

figure(8)
plot_crp_serialpos(crp_serialpos(data.recalls, data.subject, data.listLength));
set(gca, 'XTick', [1:2:24], 'YLim', [0 .7], 'YTick', 0:.1:.7)
print(gcf, '-depsc', fullfile(res_dir, res_name, 'crp_serialpos_data'))

figure(9)
% also get the likelihood version of the CRP by serial position,
% since that requires even more generated data to get clean
[err, logl, logl_all] = eval_param_tcm(param, 'data', data);
crps_model = logl_crp_serialpos(logl_all, data.recalls);
plot_crp_serialpos(crps_model);
set(gca, 'XTick', [1:2:24], 'YLim', [0 .7], 'YTick', 0:.1:.7)
print(gcf, '-depsc', ...
      fullfile(res_dir, res_name, 'crp_serialpos_model_likelihood'))

