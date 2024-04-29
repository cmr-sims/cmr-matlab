
res_dir = '~/results/tfrltp/cmr';
%model_type = 'tcm_lc_2p_1b_c-3';
model_type = 'tcm_lc_simple_was2';
res_name = 'tcm_lc_b2_p2_g_x2_t_lsa2-2';
% best_param(1) = 0.6;
% best_param(2) = 0.55;
% best_param(3) = 1.2;
% best_param(4) = .5;
% best_param(7) = .15;
search = true;
% behavioral data
data_file = '~/matlab/cmr/fr/TFRLTP/tfrltp_data_sem_co_clean.mat';
data = getfield(load(data_file, 'data'), 'data');

% model of semantics
lsa_path = '~/matlab/cmr/fr/TFRLTP/tfrltp_lsa.mat';
was_path = '~/matlab/cmr/fr/TFRLTP/tfrltp_was.mat';

% parameter information

% NWM: used for logl_was2 below
%names = {'B_enc' 'B_rec' 'P1' 'P2' 'G' 'T' 'X' 'S1' 'S2'};
%ranges = [0 1; 0 1; 0 20; 0 10; 0 1; 0 10; 0 10; -1 1; 0 10];
%start_param = [0.5 0.5 2 8 0.3 3.3 0.3 0 0.6];

% NWM: used for logl_was and logl_lsa below
%names = {'B_enc' 'B_rec' 'P1' 'P2' 'G' 'T' 'X' 'S'};
%ranges = [0 1; 0 1; 0 20; 0 10; 0 1; 0 10; 0 10; 0 10];
%start_param = [0.5 0.5 2 8 0.3 3.3 0.3 0.6];

%names = {'B' 'P1' 'P2' 'G' 'T' 'X' 'S'};
%ranges = [0 1; 0 20; 0 10; 0 1; 0 10; 0 10; 0 10];
%start_param = [0.5 2 8 0.3 3.3 0.3 0.6];
%names = {'B' 'P1' 'P2' 'G' 'T' 'X' 'C'};
%ranges = [0 1; 0 20; 0 10; 0 1; 0 100; 0 10; 0 10];
%start_param = [0.5 2 8 0.3 3.3 0.3 .01];
%start_param = [0.5 2 1 0.5 10 0.1 .5];

% NWM: used for logl_nos below
%names = {'B_enc' 'B_rec' 'P1' 'P2' 'G' 'T' 'X'};
%ranges = [0 1; 0 1; 0 20; 0 10; 0 1; 0 10; 0 10];
%start_param = [0.5 0.5 2 8 0.3 3.3 0.3];

%param_info = make_param_info(names, 'range', ranges);

%model_type = 'tcm_lc_simple';
[param_info, fixed] = search_param_tcm(model_type);

fstruct = fixed;
fstruct.data = data;
fstruct.param_info = param_info;
fstruct.sem_path = lsa_path;
%fstruct.sem_path = was_path;

% run one parameter set for testing
%param_vec = [0.5 0.5 2 8 0.5 1.5 0.4 0 3];
%param_vec = mean(ranges, 2)';
%param_vec = [0.86 0.87 1.7 1.1 0.59 2.06 0.59 0.5 0.70];
%param_vec = start_param;
%profile on; profile clear
%[err, logl, logl_all] = eval_param_tcm(param_vec, fstruct);
%profile viewer

% evaluation function
f = @(x) eval_param_tcm(x, fstruct);

% run parameter search
if search
  options = optimset('Display', 'iter');
  tic
  start_param = [param_info.start];
  ranges = cat(1, param_info.range);
  [best_param, fval, exitflag, output] = fminsearchbnd(f, start_param, ...
                                                    ranges(:,1), ...
                                                    ranges(:,2), options);
  toc
  res_file = fullfile(res_dir, model_type, [res_name '_fmsb1.mat']);
  if ~exist(fileparts(res_file), 'dir')
    mkdir(fileparts(res_file))
  end
  parameters = best_param;
  fitness = fval;
  save(res_file, 'parameters', 'fitness', 'param_info')
end
  
% run best parameter set
[err, logl, logl_all] = eval_param_tcm(best_param, fstruct);
crps_model = logl_crp_serialpos(logl_all, data.recalls);

fig_dir = fullfile(res_dir, model_type, [res_name '_fmsb1']);
if ~exist(fig_dir, 'dir')
  mkdir(fig_dir)
end

% summary stats of interest
figure(1)
clf
plot_crp_serialpos(crps_model);
set(gca, 'YLim', [0 .7], 'YTick', 0:.1:.7)
print(gcf, '-depsc', fullfile(fig_dir, 'crp_serialpos_model'))

crps = crp_serialpos(data.recalls, data.listLength, data.subject);
figure(2)
clf
plot_crp_serialpos(crps);
set(gca, 'YLim', [0 .7], 'YTick', 0:.1:.7)
print(gcf, '-depsc', fullfile(fig_dir, 'crp_serialpos_data'))

return

% NWM: results of various semantic model searches
k = 8;
logl_lsa = -30733.9; % see above for free parameters
logl_was = -30520;
logl_was2 = -30448.7;
logl_nos = -31324; % no semantics, C=0
aic_lsa = (2 * k) - (2 * logl_lsa);
aic_was = (2 * k) - (2 * logl_was);

d = -2 * logl_nos + 2 * logl_lsa;

% NWM: from AIC wikipedia page; not sure this is right. Says the
% relative likelihood that LSA generated the data is basically 0,
% compared to WAS
p_was = 1 - exp((aic_was - aic_lsa) / 2);

% Very simple model; stopping rule based on a negative exponential
% function of total activation. One-item primacy.
% B P G X
% -32436.3
%
% Using a primacy gradient instead of only affect item 1.
% B P1 P2 G X
% -32213.1
%
% Adding a constant strength parameter.
% B P1 P2 G X C
% -31961.6
%
% Splitting B into two parameters, B1: encoding, B2: retrieval.
% B1 B2 P1 P2 G X C
% -31754.8
%
% Adding tau to control the sensitivity of the Luce choice rule.
% B1 B2 P1 P2 G X C T
% -31350.1
%
% Moved here to a different stopping rule. Now stop probability is
% an exponential function as output position, with X1 setting the
% probability of recalling no items.
% B1 B2 P1 P2 G X1 X2 C T
% -30181.4
%
% Mcf is initialized to a scaled version of WAS cosine similarity
% values. The intercept for mapping similarity to associative strength
% is assumed to be 0 (where 0 is the lowest cosine similarity
% pairwise value in the wordpool, and the highest similarity is 1).
% B1 B2 P1 P2 G X1 X2 S2 T (WAS)
% -30260.9
%
% As above, but letting the intercept of the similarity-strength
% function vary freely.
% B1 B2 P1 P2 G X1 X2 S1 S2 T (WAS)
% -30158.1
%
% One-parameter semantic similarity with LSA.
% B1 B2 P1 P2 G X1 X2 S2 T (LSA)
% -30444.7
%
% Two-parameter semantic similarity with LSA.
% B1 B2 P1 P2 G X1 X2 S1 S2 T (LSA)
% -30375.3
% with S2 start at 0.1 instead of 0.5:
% -30189.2
