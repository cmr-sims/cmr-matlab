

opt.data = 'tfrltp_data_sem_co_clean';
opt.sem_path = 'tfrltp_lsa.mat';

param_info(1).name = 'B_enc';
param_info(1).vector_index = 1;
param_info(2).name = 'B_rec';
param_info(2).vector_index = 2;

param_info(3).name = 'P1';
param_info(3).vector_index = 3;
param_info(4).name = 'P2';
param_info(4).vector_index = 4;

param_info(5).name = 'G';
param_info(5).vector_index = 5;

param_info(6).name = 'S';
param_info(6).vector_index = 6;

param_info(7).name = 'T';
param_info(7).vector_index = 7;
param_info(8).name = 'X';
param_info(8).vector_index = 8;

opt.param_info = param_info;
opt.f_logl = @tcm_general;

% p_vec  [B_e  B_r  P1    P2   G    S    T    X]
ranges = [0 1; 0 1; 0 10; 0 5; 0 1; 0 10; 0 5; 0 5]';

% ranges = [0 1; 1.6 1.6; 0.31 0.31; 0.47 0.47; 0.1 0.1; 0.3 0.3; 0 0; 2.7 2.7; 0.3 0.3]';

func = @eval_param_tcm;
func_input = {opt};

% create the initial x0 for this run of fminsearchbnd
% num_params = size(ranges,2);
% start_param = rand(1, num_params);    
% diffs = diff(ranges);
% mins = ranges(1,:);
% start_param = (start_param .* diffs) + mins;
% start_param = [0.5 2 8 0.3 3.3 0.3 0.6];
% start_param = [0.5 2 0.2 0.8 1 0.3 0 1.2 0.3];

% options = optimset('Display', 'iter');
% [best_param,fval,exitflag,output] = fminsearchbnd(@(x) eval_param_tcm(x, opt), ...
%                                                   start_param, ...
%                                                   ranges(1,:), ...
%                                                   ranges(2,:), ...
%                                                   options);

res_dir = '~/sims/TFRLTP';
res_name = 'tcm_general_sem_lsa_v2';
dce_options.num_fits = 25;
dce_options.walltime = '06:00:00';

res_file = run_fmsb_dce(func, func_input, ranges, ...
                        res_dir, res_name, dce_options);


