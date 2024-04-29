
% behavioral data
data_file = '~/matlab/cmr_trunk/fr/TFRLTP/tfrltp_data_sem_co_clean.mat';
beh_data = getfield(load(data_file, 'data'), 'data');
[beh_data.recalls, beh_data.rec_items, beh_data.rec_itemnos, beh_data.times, ...
 beh_data.intrusions] = trim_padding(beh_data.recalls, beh_data.rec_items, ...
                                 beh_data.rec_itemnos, beh_data.times, ...
                                 beh_data.intrusions);

% % remove trials where all items were recalled
% beh_data = trial_subset(sum(beh_data.recalls ~= 0, 2) < ...
%                         size(beh_data.pres_itemnos, 2), ...
%                         beh_data);

% write semantics to text
sem_file = '~/matlab/cmr_trunk/likelihood/mcmc/data/was_mat.txt';
sem_mat_file = 'tfrltp_was.mat';
load(sem_mat_file);
write_sem_tcmbin(sem_mat, sem_file);

% write item numbers to text
itemno_file = '~/matlab/cmr_trunk/likelihood/mcmc/data/tfrltp_itemno.txt';
write_itemno_tcmbin(beh_data.pres_itemnos, itemno_file);

% standard parameters, for comparison with cc code
param = struct;
param.B_enc = 0.9;
%param.B_enc = linspace(0, 1, 41);
param.B_rec = 0.6;
param.C = 0.1;
param.G = 0.5;
param.P1 = 2;
param.P2 = 1;
param.T = 1;
param.X1 = 0.001;
param.X2 = 0.3;
param.S1 = 0;
param.S2 = 0.5;
param.sem_path = sem_mat_file;
param.sem_file = sem_file;
param.itemno_file = itemno_file;
param = check_param_tcm(param);
index = make_index(beh_data.subject);
[logl, logl_all] = tcm_general(param, beh_data, index);
squeeze(exp(logl_all(1,1:12,:)))
beh_data.recalls(1,1:11)

tic; logl_trial = tcm_general(param, beh_data); logl = nansum(logl_trial(:)); toc
data_file = '~/matlab/cmr_trunk/likelihood/mcmc/data/tfrltp_tcm_cpp.txt';
param_file = '~/matlab/cmr_trunk/likelihood/mcmc/src/param.txt';
tic; logl = tcm_general_bin(param, data_file); toc

%% test the binary code on maximum likelihood searches
[param_info, fixed] = search_param_tcm('tcm_mcmc');
fstruct = fixed;
fstruct.data = data_file;
fstruct.param_info = param_info;
fstruct.f_logl = @tcm_general_bin;
fstruct.load_data = false;
options = optimset('Display', 'iter');
start_param = [param_info.start];
ranges = cat(1, param_info.range)';
f = @(x) eval_param_tcm(x, fstruct);

[best_param, fval] = de_search(f, ranges, 'generations', 400, ...
                               'popsize', 100);
[best_param, fval, exitflag, output] = fminsearchbnd(f, best_param, ...
                                                     ranges(1,:), ...
                                                     ranges(2,:), options);
% run 1: 30177.3

% 100 gen, 1: de 30270.6, fmin 30179.7
% 100 gen, 2: de 30267.8, fmin 30175.4

% 200 gen, 1: de 30180.9, fmin 30176.7
% 200 gen, 2: de 30179.6, fmin 30175.3
% 200 gen, 3: de 30180.7, fmin 30175.4

% with new parameter ranges:
% 200 gen, 1: de 30182.4, fmin 30174.1
% 200 gen, 2: de 30170.8, fmin 30167

% varying all but T, fixed at 10:
% 400 gen, 1: de 30300.4, fmin 30300.4
% 400 gen, 100 indiv: de 30300.4, fmin 30300.4

% varying all:
% 400 gen, 100 indiv: de 30166.7, fmin 30166.7

p = recall_mat2vec(beh_data.recalls, exp(logl_all));
cpp_out_file = '~/matlab/cmr_trunk/likelihood/bugs/src/output.txt';
s = load(cpp_out_file, 'ascii');

param = struct;
param.B_enc = 0.89577;
param.B_rec = 0.86019;
param.C = 0.02073;
param.G = 0.50297;
param.T = 1;
param.P1 = 3.13627;
param.P2 = 1;
param.X1 = 0.001;
param.X2 = 0.29922;
param = check_param_tcm(param);
seq = gen_tcm(param, beh_data);

% create behavioral figures
beh_dir = '/Users/morton/results/tfrltp/figs';
res_dir = '/Users/morton/results/tfrltp/bugs';
analyses = {'spc' 'crp' 'crp_serialpos' 'p_stop'};
res_beh = stats_tfrltp(beh_data, analyses, beh_dir);
res_beh_indiv = indiv_report_tfrltp(beh_data, analyses, beh_dir);

% write out data for MCMC
out_file = '/Users/morton/matlab/cmr_trunk/likelihood/bugs/data/full_tcm_data_cpp.R';
write_bugs_full_tcm(beh_data, out_file, [], 'jags_cpp');

% two subjects
out_file = '/Users/morton/matlab/cmr_trunk/likelihood/bugs/data/full_tcm_data_cpp_2subj.R';
write_bugs_full_tcm(beh_data, out_file, 2, 'jags_cpp');

% write out data for testing cpp version
out_file = '/Users/morton/matlab/cmr_trunk/likelihood/bugs/data/full_tcm_recalls.txt';
write_bugs_full_tcm(beh_data, out_file, [], 'text');

% run MCMC in JAGS through R using rjags...see import_jags.R

% results written out from R
%model_type = 'full_tcm_1p_trim_vec_x2_b2_c_t_group9';
model_type = 'full_tcm_cpp_group2';
mcmc_file = fullfile(res_dir, model_type, 'mcmc.txt');
param = read_mcmc(mcmc_file);

% must set fixed params manually, from the model file used for the
% MCMC
param.T = 10;
param.X1 = 0.01;
param.P2 = 1;
param.stop_rule = 'ratio';
param = check_param_tcm(param);

% generate data from the expected values of the parameters
index = make_index(beh_data.subject);
n_rep = 10;
seq = gen_tcm(param, beh_data, n_rep, index);

% get a compatible data struct
data = struct;
data.subject = repmat(beh_data.subject, [n_rep 1]);
data.recalls = seq;
data.listLength = beh_data.listLength;

% create group-level figures
fig_dir = fullfile(res_dir, model_type, 'figs');
if ~exist(fig_dir, 'dir')
  mkdir(fig_dir)
end
stat_file = fullfile(res_dir, model_type, 'sim_stats.mat');
save(stat_file, 'param', 'data', 'mcmc_file', 'model_type');
res_net = stats_tfrltp(data, analyses, fig_dir);
res_net_indiv = indiv_report_tfrltp(data, analyses, fig_dir);

