
% fstruct.datapath = '/Users/polyn/SCIENCE/EXPERIMENTS/apem_e7/results';
%fstruct.datapath = '/home1/polyn/experiments/apem_e7/results/data.mat';

clear options fstruct

res_dir = '~/results/tfr/cmr';
start_file = fullfile(res_dir, 'ga3');

% information for running simulation
fstruct.datapath = 'PolyEtal09_data.mat';
fstruct.sem_path = 'LSA_tfr.mat';
fstruct.gaparam = ga_param_orig;
fstruct.wtvec = wtvec_ones;
fstruct.mult_subj = 3;

% load the behavioral data
load(fstruct.datapath);
load(fstruct.sem_path);

% get the behavioral results
[fstruct.behav_resvec, fstruct.behav_semvec] = ...
                           gamut_of_analyses_optim(data.full, sem_mat);

% create the ranges for the genetic algorithm
ranges = NaN(2, length(fstruct.gaparam));
for i = 1:length(fstruct.gaparam)
  ranges(:,fstruct.gaparam(i).vector_index) = fstruct.gaparam(i).range;
end

% CUSTOMIZE THESE FOR EACH RUN
% options.popsize = 1050;
% options.numGroups = 30;
% options.generations = 10;
% options.numsave = 0.2;
% options.mutP = 0.02;
% options.fileRoot = 'ga_cmr_full1';
% options.startFile = 'grid_cmr_full1.txt';
% options.print_erfvec = 1;

% set random seeds (very important)
rstate = sum(100*clock);
rand('state', rstate);
rnstate = sum(100*clock);
randn('state', rnstate);

t0 = clock;

options.start_file = start_file;
options.popsize = 500;
options.generations = 4;
options.num_groups = 100;
options.group_size = options.popsize / options.num_groups;
options.num_parents = 50;
options.num_recombine = options.popsize - options.num_parents;
options.mutation_percent = 0.05;
options.collect_erfvec = true;
options.walltime = '00:30:00';

%G = runga(@eval_taskFR,ranges,options,fstruct);
[G, res_file] = run_ga_dce(@eval_taskFR, {fstruct}, ranges, res_dir, ...
                           'ga3', options);

fprintf('Total Time: %g\n\n', etime(clock, t0));
