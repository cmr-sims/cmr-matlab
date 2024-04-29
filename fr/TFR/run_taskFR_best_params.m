function [res, data, param] = run_taskFR_best_params(res_file)
%RUN_TASKFR_BEST_PARAMS   Run taskFR using the best parameters from a search.
%
%  [res, data, param] = run_taskFR_best_params(res_file)

% load the winning parameters
gaparam = ga_param_orig;
param = load_best_params(res_file, gaparam);

% run a simulation
data = run_taskFR(param, 'PolyEtal09_data.mat');

% analyze
load('LSA_tfr.mat')
noise_var = 0.41;
noise_mat = sqrt(noise_var) * randn(size(sem_mat));
res = analyze_taskFR(data, sem_mat, noise_mat);

