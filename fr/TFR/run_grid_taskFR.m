clear options fstruct

res_dir = '~/results/tfr/cmr';

% information for running simulation
fstruct.datapath = 'PolyEtal09_data.mat';
fstruct.sem_path = 'LSA_tfr.mat';
fstruct.gaparam = ga_param_orig;
fstruct.wtvec = wtvec_ones;
fstruct.mult_subj = 1;

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

% set random seeds (very important)
rstate = sum(100*clock);
rand('state', rstate);
rnstate = sum(100*clock);
randn('state', rnstate);

t0 = clock;

options.popsize = 8000;
options.generations = 1;
options.num_groups = 100;
options.group_size = options.popsize / options.num_groups;
options.collect_erfvec = true;
options.walltime = '06:00:00';

[G, res_file] = run_ga_dce(@eval_taskFR, {fstruct}, ranges, res_dir, ...
                           'grid2', options);

fprintf('Total Time: %g\n\n', etime(clock, t0));
