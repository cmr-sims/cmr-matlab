
%res_dir = '~/sims/P09';
res_dir = '~/results/p09/cmr';
res_name = 'tcm_lc_2p_sem_Lfit3';

load PolyEtal09_data;
data = data.co;

load LSA_tfr;
% trying a version where we remove the self-similarities and
% rescale the rest of the cosine association scores to be between 0
% and 1.
temp = sem_mat;
temp(1:size(sem_mat,1)+1:end) = 0;
v = temp(:);
smin = min(v);
smax = max(v);
sem_mat = (temp - smin) / (smax - smin);
% SMP: there is something odd about setting the self-connections to
% zero given that the diagonals of cf are set to zero, so in a
% sense, a memory supports its associates better than it supports itself 
sem_mat(1:size(sem_mat,1)+1:end) = 0;
% save this sem_mat to disk, then pass the path to the sem_mat
sem_mat = single(sem_mat);

sem_path = fullfile(res_dir, 'tfr_sem_mat');
save(sem_path, 'sem_mat', '-v6');

recs = data.recalls;
rec_mask = make_clean_recalls_mask2d(recs);

rec_clean = zeros(size(recs));
for i = 1:size(recs,1)
    this_seq = recs(i, make_clean_recalls_mask2d(recs(i,:)));
    rec_clean(i,1:length(this_seq)) = this_seq;
end

func = @eval_model;
fstruct = struct;
fstruct.modelfn = @tcm_lc_2p_sem;
fstruct.recalls = rec_clean;
fstruct.LL = 24;
fstruct.ntrials = size(rec_clean,1);
fstruct.pres_itemnos = data.pres_itemnos;
fstruct.sem_path = sem_path;

func_input = {fstruct};
ranges = [0 1; 0 20; 0 10; 0 1; 0 10; 0 10; 0 10]';
% fieldnames = {'B' 'P1' 'P2' 'G' 'T' 'X' 'S'};
% ranges = [0 1; 2 2; 8 8; 0.3 0.3; 3.3 3.3; 0.3 0.3; 0.6 0.6]';

options.num_fits = 50;
options.walltime = '24:00:00';

% % % SMP: this works now
param_vec = [0.5 2 8 0.5 1.5 0.4 3];
L = eval_model(param_vec, fstruct);
return
% NWM: new version
load ~/results/p09/cmr/lc_2p_sem/best_param_rmsb.mat
param_info = make_param_info({'B_enc' 'B_rec' 'P1' 'P2' 'G' 'T' 'X' 'S'});
data.recalls = rec_clean;
[err, logl, logl_all] = eval_param_tcm(parameters, 'data', data, ...
                                       'param_info', param_info, ...
                                       'sem_path', sem_path, ...
                                       'verbose', true);

% SMP: this works now
% SMP: trying fmin version prior to dce version
% find the best fit parameters for P09
% create the initial x0 for this run of fminsearchbnd
% num_params = size(ranges,2);
% start_param = rand(1, num_params);    
% diffs = diff(ranges);
% mins = ranges(1,:);
% start_param = (start_param .* diffs) + mins;
start_param = [0.5 2 8 0.3 3.3 0.3 0.6];

% tic
% options = optimset('Display', 'iter');
% [best_param,fval,exitflag,output] = fminsearchbnd(@(x) eval_model(x,fstruct), ...
%                                                   start_param, ...
%                                                   ranges(1,:), ...
%                                                   ranges(2,:), ...
%                                                   options);
% toc

tic
options = optimset('Display', 'iter');
names = {'B_enc' 'B_rec' 'P1' 'P2' 'G' 'T' 'X' 'S'};
ranges = [0 1; 0 1; 0 20; 0 10; 0 1; 0 10; 0 10; 0 10];
param_info = make_param_info(names, 'range', ranges);
fstruct = struct;
fstruct.data = data;
fstruct.data.recalls = rec_clean;
fstruct.param_info = param_info;
fstruct.sem_path = sem_path;
f = @(x) eval_param_tcm(x, fstruct);
%start_param = mean(ranges, 2);
start_param = [0.5 0.5 2 8 0.3 3.3 0.3 0.6];
[best_param, fval, exitflag, output] = fminsearchbnd(f, start_param, ...
                                                     ranges(:,1), ...
                                                     ranges(:,2), options);
toc

% search_dir = fullfile(res_dir, 'lc_2p_sem');
% res_name = 'de1';
% opt = struct;
% opt.popsize = 50;
% opt.strategy = 2;
% opt.step_weight = 0.85;
% opt.crossover = 1;
% opt.range_bound = 1;
% opt.collect_erfvec = false;
% tic
% res_file = run_de_serial(func, func_input, ranges, search_dir, ...
%                          res_name, opt); toc

% % SMP: working up to this! first get the rest working
% res_file = run_fmsb_dce(func, func_input, ranges, ...
%                        res_dir, res_name, options); 




