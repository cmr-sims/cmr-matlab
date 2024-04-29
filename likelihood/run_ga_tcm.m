
% a template for genetic algorithm runs

load MurdData;
recs = data.LL{1}.recalls;
rec_mask = make_clean_recalls_mask2d(recs);

rec_clean = zeros(size(recs));
for i = 1:size(recs,1)
    this_seq = recs(i, make_clean_recalls_mask2d(recs(i,:)));
    rec_clean(i,1:length(this_seq)) = this_seq;
end

struct.LL = 20;
struct.modelfn = @tcm_lc_2p;
struct.genfn   = @gen_tcm_lc_2p;
struct.rec_mat = rec_clean;
struct.ntrials = 1200;

% use rec_mat to generate summary statistics from the actual data
sp = mean(spc(rec_clean,data.subject(1:120),struct.LL));
lc = mean(crp(rec_clean,data.subject(1:120),struct.LL));
pos = [struct.LL-5:struct.LL-1 struct.LL+1:struct.LL+5];
struct.summary = [sp lc(pos)];


% Bare bones version of TCM for exploration.
% - just one Beta parameter (enc=rec) [B 0-1]
% - primacy exponent [P 0-50]
% - gamma_fc (gamma_cf fixed) [G 0-1]
% - luce-choice with tau paramter from HK02 [T 0-10]
% - pstop is negative exponential with decay parameter [S 0-10]
% - primacy decay [0 10]

% create the ranges for the genetic algorithm
ranges =     [0 1;...
              0 50;...
              0 1;...
              0 10;...
              0 10;...
              0 10]';

res_dir = '~/sims/tcm_lc/';
res_name = 'tfrs_lik1';
start_file = [];

options.start_file = start_file;
options.popsize = 30000;
options.generations = 10;
options.num_groups = 100;
options.group_size = options.popsize / options.num_groups;
options.num_parents = 50;
options.num_recombine = options.popsize - options.num_parents;
options.mutation_percent = 0.05;
options.collect_erfvec = false; %make sure this is set to false
options.walltime = '00:30:00';

[res_file] = run_ga_dce(@eval_model_ga, {struct}, ranges, res_dir, ...
                           res_name, options);

