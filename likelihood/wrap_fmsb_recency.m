
res_dir = '~/results/tfrltp/cmr';
model_type = 'tcm_lc_recency';
res_name = 'tcm_lc_b_p2_c-2';
search = true;

% behavioral data
data_file = '~/matlab/cmr/fr/TFRLTP/tfrltp_data_sem_co_clean.mat';
data = getfield(load(data_file, 'data'), 'data');

%names = {'B_enc' 'P1'};
%ranges = [0 1; 0 10000000];
%start_param = [.5 1];
names = {'B_enc' 'P1' 'C'};
ranges = [0 1; 0 1000000000; 0 1];
start_param = [.5 100000 .1];

param_info = make_param_info(names, 'range', ranges);

fstruct = struct;
fstruct.data = data;
fstruct.param_info = param_info;
fstruct.f_logl = @tcm_recency;
fstruct.P2 = 10;

% evaluation function
f = @(x) eval_param_tcm(x, fstruct);

% run parameter search
if search
  options = optimset('Display', 'iter');
  tic
  [best_param, fval, exitflag, output] = fminsearchbnd(f, start_param, ...
                                                    ranges(:,1), ...
                                                    ranges(:,2), options);
  toc
end
%best_param = [.9 10000000];
param = unpack_param(best_param, param_info);
param = check_param_tcm(param);
[logl, logl_all, p] = tcm_recency(param, data);

fig_dir = fullfile(res_dir, res_name);
if ~exist(fig_dir, 'dir')
  mkdir(fig_dir)
end
plot_spc(p);
set_fig_style(gcf, 'minimal')
print(gcf, '-depsc', fullfile(fig_dir, 'pfr'))

return
% write out model information for BUGS
load('/Users/morton/results/tfrltp/cmr/tcm_lc_2p_1b_c/fmsb1.mat')
param = unpack_param(parameters, param_info);
param = check_param_tcm(param);

out_file = '/Users/morton/matlab/cmr/likelihood/bugs/recency_tcm_data.txt';
write_recency_bugs_tcm(data, param, out_file);

% B P1
% 0.77 2020
% -1814.92
%
% B P1 (hand)
% .9 10000000
% -2016.8
%
% B P1 C
% 0.91 2.3654e+07 0.0065
% -1634.34

