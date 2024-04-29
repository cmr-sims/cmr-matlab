
% a template for fminsearch

load data.mat %make sure this is grabbing the correct data struct!
load('/scratch/polynlab/kragelje/exp.mat')
recs = data.recalls(1:120,:);
rec_mask = make_clean_recalls_mask2d(recs);

rec_clean = zeros(size(recs));
for i = 1:size(recs,1)
    this_seq = recs(i, make_clean_recalls_mask2d(recs(i,:)));
    rec_clean(i,1:length(this_seq)) = this_seq;
end

struct.LL = 24;
struct.modelfn = @tcm_lc_neural;
struct.genfn   = @gen_tcm_lc_neural;
struct.rec_mat = rec_clean;
struct.ntrials = 1200;

%read these in from neural data. for now, just make this up from recall data

iM = [   -0.3333         0         0   26.0000
    0    0.3333         0   37.3333
    0         0    0.3333   16.6667
    0         0         0    1.0000];

invox = [-6 -73 58]; %dACC
% invox = [0 23 37]; %dPPC

outvox = invox*iM(1:3,1:3)+iM(1:3,4)';
data = add_st_beta(data,exp,outvox');

x = data.pres.st_beta;
tm = min(x,[],2); tm2 = max(x,[],2);

struct.neural_mat = (x-repmat(tm,1,size(x,2)))./(repmat(tm2,1,size(x,2))-repmat(tm,1,size(x,2))); %scales so min


% use rec_mat to generate summary statistics from the actual data
sp = mean(spc(rec_clean,data.subject(1:120),struct.LL));
lc = mean(crp(rec_clean,data.subject(1:120),struct.LL));
pos = [struct.LL-5:struct.LL-1 struct.LL+1:struct.LL+5];
struct.summary = [sp lc(pos)];


% Bare bones version of TCM for exploration.
% - just one Beta parameter (enc=rec) [B 0-1]
% - one-parameter primacy process [P 0-?]
% - gamma_fc (gamma_cf fixed) [G 0-1]
% - luce-choice with tau paramter from HK02 [T 0-inf]
% - pstop is negative exponential with decay parameter [S ?-?]

% create the ranges for the genetic algorithm
ranges =     [0 1;...
    0 50;...
    0 1;...
    0 10;...
    0 10;...
    0 10;...
    0 20]';

res_dir = '~/sims/tcm_lc/';
res_name = 'tfrs_dACC2';
start_file = [];

options.start_file = start_file;
options.popsize = 150000;
options.generations = 10;
options.num_groups = 100;
options.group_size = options.popsize / options.num_groups;
options.num_parents = 50;
options.num_recombine = options.popsize - options.num_parents;
options.mutation_percent = 0.05;
options.collect_erfvec = false; %make sure this is set to false
options.walltime = '00:30:00';

[res_file] = run_ga_dce(@eval_model_ga_neural, {struct}, ranges, res_dir, ...
                           res_name, options);

