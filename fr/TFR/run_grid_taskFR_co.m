
% fstruct.datapath = '/Users/polyn/SCIENCE/EXPERIMENTS/apem_e7/results';
fstruct.datapath = '/home1/polyn/experiments/apem_e7/results';

% load the behavioral data
here = pwd;
cd(fstruct.datapath);
load data;
cd(here);

% get the behavioral results
[fstruct.behav_resvec,fstruct.behav_semvec] = gamut_of_analyses_co_optim(data);

fstruct.gaparam = ga_param_co1;
fstruct.wtvec = wtvec_f1co;
fstruct.encodVar = 1;
fstruct.justControl = 1;
fstruct.customAnaFn = @gamut_of_analyses_co_optim;

% create the ranges for the genetic algorithm
for i=1:length(fstruct.gaparam)
  ranges(1:2,fstruct.gaparam(i).vector_index) = fstruct.gaparam(i).range;
end

options.popsize = 2000;
options.numGroups = 20;
options.generations = 1;
options.numsave = 0.2;
options.mutP = 0.02;
options.fileRoot = 'grid_cmr_co1';
% options.startFile = '';

% set random seeds (very important)
rand('state',sum(100*clock)); % resets generator to a new state
randn('state',sum(100*clock)); % resets generator to a new state

t0 = clock;

options.print_erfvec = 1;

G = runga(@eval_taskFR,ranges,options,fstruct);

fprintf('Total Time: %g\n\n',etime(clock,t0));
